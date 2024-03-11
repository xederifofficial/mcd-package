This repository is used to produce a multi-arch Docker images for testnet and mainnet mobilecoind.

The intended workflow for releasing a new version is:
1. Create a branch off `main`.
2. Make whatever changes you need to the `mobilecoin` submodule.
3. PR and merge bak to `main`.
4. Tag `main` - name the tag something descriptive that points at the MobileCoin release version (e.g. `mcd-memos-v5.2.3`, `mcd-memos-v5.2.3-ii`, etc) and push the tag to this repository.
5. Manually run the `release-to-dockerhub` workflow and select the newly created tag. The action takes a few hours to run and builds two docker images. They will be named `public.ecr.aws/f8p9h8d2/mobilecoind-test:tagname` and `public.ecr.aws/f8p9h8d2/mobilecoind-prod:tagname`, where tag name is the tag that the action is running against. Additionally, the action will also push a `:latest` tag for each of the two images.
