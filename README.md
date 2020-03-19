# Terraform Test

This is a replication of https://github.com/terraform-linters/tflint/issues/452 for Terraform `v0.12.x`

I run this by doing the following commands
```
❯ cd infra/prod
❯ terraform init
❯ terraform apply
❯ docker run --rm -e TFLINT_LOG=debug -v $(pwd):/data -t wata727/tflint --module
17:21:01 config.go:83: [INFO] Load config: .tflint.hcl
17:21:01 config.go:95: [INFO] Default config file is not found. Ignored
17:21:01 config.go:104: [INFO] Load fallback config: /root/.tflint.hcl
17:21:01 config.go:112: [INFO] Fallback config file is not found. Ignored
17:21:01 config.go:114: [INFO] Use default config
17:21:01 option.go:51: [DEBUG] CLI Options
17:21:01 option.go:52: [DEBUG]   Module: true
17:21:01 option.go:53: [DEBUG]   DeepCheck: false
17:21:01 option.go:54: [DEBUG]   Force: false
17:21:01 option.go:55: [DEBUG]   IgnoreModules: map[string]bool{}
17:21:01 option.go:56: [DEBUG]   EnableRules: []string(nil)
17:21:01 option.go:57: [DEBUG]   DisableRules: []string(nil)
17:21:01 option.go:58: [DEBUG]   Varfiles: []string{}
17:21:01 option.go:59: [DEBUG]   Variables: []string{}
17:21:01 loader.go:55: [INFO] Initialize new loader
17:21:01 loader.go:66: [INFO] Module manifest file found. Initializing...
17:21:01 loader.go:262: [DEBUG] Parsing the module manifest file: {"Modules":[{"Key":"","Source":"","Dir":"."},{"Key":"test","Source":"../../modules/test","Dir":"../../modules/test"}]}
17:21:01 loader.go:80: [INFO] Load configurations under .
17:21:01 loader.go:95: [INFO] Module inspection is enabled. Building a root module with children...
17:21:01 loader.go:244: [DEBUG] Trying to load the module: key=test, version=, dir=../../modules/test
17:21:01 loader.go:102: [ERROR] Failed to load modules: <nil>: Failed to read module directory; Module directory ../../modules/test does not exist or cannot be read.
Failed to load configurations. 1 error(s) occurred:

Error: Failed to read module directory

Module directory ../../modules/test does not exist or cannot be read.

```

This fails because we are bind mounting within the root module directory but the modules we are consuming are outside of our view, so we can work around this by running the following commands from the ROOT of the git repository:
```
❯ terraform init
❯ terraform apply
❯ docker run --rm -e TFLINT_LOG=debug -v $(pwd):/data -t wata727/tflint /data/infra/prod --module
17:20:08 config.go:83: [INFO] Load config: .tflint.hcl
17:20:08 config.go:95: [INFO] Default config file is not found. Ignored
17:20:08 config.go:104: [INFO] Load fallback config: /root/.tflint.hcl
17:20:08 config.go:112: [INFO] Fallback config file is not found. Ignored
17:20:08 config.go:114: [INFO] Use default config
17:20:08 option.go:51: [DEBUG] CLI Options
17:20:08 option.go:52: [DEBUG]   Module: true
17:20:08 option.go:53: [DEBUG]   DeepCheck: false
17:20:08 option.go:54: [DEBUG]   Force: false
17:20:08 option.go:55: [DEBUG]   IgnoreModules: map[string]bool{}
17:20:08 option.go:56: [DEBUG]   EnableRules: []string(nil)
17:20:08 option.go:57: [DEBUG]   DisableRules: []string(nil)
17:20:08 option.go:58: [DEBUG]   Varfiles: []string{}
17:20:08 option.go:59: [DEBUG]   Variables: []string{}
17:20:08 loader.go:55: [INFO] Initialize new loader
17:20:08 loader.go:66: [INFO] Module manifest file found. Initializing...
17:20:08 loader.go:262: [DEBUG] Parsing the module manifest file: {"Modules":[{"Key":"","Source":"","Dir":"infra/prod"},{"Key":"test","Source":"../../modules/test","Dir":"modules/test"}]}
17:20:08 loader.go:80: [INFO] Load configurations under /data/infra/prod
17:20:08 loader.go:95: [INFO] Module inspection is enabled. Building a root module with children...
17:20:08 loader.go:244: [DEBUG] Trying to load the module: key=test, version=, dir=/data/infra/prod/modules/test
17:20:08 loader.go:102: [ERROR] Failed to load modules: <nil>: Failed to read module directory; Module directory /data/infra/prod/modules/test does not exist or cannot be read.
Failed to load configurations. 1 error(s) occurred:

Error: Failed to read module directory

Module directory /data/infra/prod/modules/test does not exist or cannot be read.
```

So what am I supposed to do here? It is not correctly following the `../../modules/test` relative path like terraform does.
