workflow "build" {
  resolves = ["GitHub Action for Docker"]
  on = "check_run"
}

action "GitHub Action for Docker" {
  uses = "actions/docker/cli@86ab5e854a74b50b7ed798a94d9b8ce175d8ba19"
  runs = "docker build -t meedamian/bitcoind 0.17/"
}
