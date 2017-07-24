# This file defines derivations built by Hydra
with import ./deps.nix {};

let
  pkgs = import <nixpkgs> {};
  images = import ./image.nix {};
  controller = import ./controller.nix {};

  # We want that Hydra generate a link to be able to manually download the image
  dockerImageBuildProduct = image: pkgs.runCommand "${image.name}" {} ''
    mkdir $out
    ln -s ${images.dockerContrailApi.out} $out/image.tar.gz
    mkdir $out/nix-support
    echo "file gzip ${images.dockerContrailApi.out}" > $out/nix-support/hydra-build-products
  '';

  dockerPushImage = image:
    let
      imageRef = "${image.imageName}:${image.imageTag}";
      registry = "localhost:5000";
    in
      pkgs.runCommand "docker-push-${image.imageName}-${image.imageTag}" {
      buildInputs = [ pkgs.jq skopeo ];
      } ''
      # The image generated by nix doesn't contain the manifest and
      # the json image configuration. We generate them and then pushed
      # the image to a registry.

      mkdir temp
      cd temp
      echo "Unpacking image..."
      tar -xf ${image.out}
      chmod a+w ../temp

      LAYER=$(find ./ -name layer.tar)
      LAYER_PATH=$(find -type d -printf %P)
      LAYER_JSON=$(find ./ -name json)
      LAYER_SHA=$(sha256sum $LAYER | cut -d ' ' -f1)

      echo "Creating image config file..."
      cat $LAYER_JSON | jq ". + {\"rootfs\": {\"diff_ids\": [\"sha256:$LAYER_SHA\"], \"type\": \"layers\"}}" > config.tmp
      CONFIG_SHA=$(sha256sum config.tmp | cut -d ' ' -f1)
      mv config.tmp $CONFIG_SHA.json

      echo "Creating image manifest..."
      jq -n "[{\"Config\":\"$CONFIG_SHA.json\",\"RepoTags\":[\"${imageRef}\"],\"Layers\":[\"$LAYER_PATH/layer.tar\"]}]" > manifest.json

      echo "Packing image..."
      tar -cf image.tar manifest.json $CONFIG_SHA.json $LAYER_PATH

      echo "Pushing unzipped image ${image.out} ($(du -hs image.tar | cut -f1)) to registry ${registry}/${imageRef} ..."
      skopeo --insecure-policy  copy --dest-tls-verify=false --dest-cert-dir=/tmp docker-archive:image.tar docker://${registry}/${imageRef} > skipeo.log
      skopeo --insecure-policy inspect --tls-verify=false --cert-dir=/tmp docker://${registry}/${imageRef} > $out
    '';
in
  { contrailApi = controller.contrailApi;
    contrailControl = controller.contrailControl;
    contrailVrouterAgent = controller.contrailVrouterAgent;
    contrailAnalytics = controller.contrailAnalytics;
  } //
  (pkgs.lib.mapAttrs (n: v: dockerImageBuildProduct v) images) //
  (pkgs.lib.mapAttrs' (n: v: pkgs.lib.nameValuePair ("docker-push-" + n) (dockerPushImage v)) images)

