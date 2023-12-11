# PowerShell Terraform Tools

[![license](https://img.shields.io/github/license/ptavares/powershell-terraform-tools)](./LICENSE)

![PowerShell Gallery Version (including pre-releases)](https://img.shields.io/powershellgallery/v/terraform-tools)

![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/terraform-tools)


## Description 

A [PowerShell](https://microsoft.com/powershell) module for [Terraform](https://www.terraform.io/), a tool from [Hashicorp](https://www.hashicorp.com/) for managing infrastructure safely and efficiently.

It will install the following [Terraform](https://www.terraform.io/) tools : 
- [terraform-docs](https://github.com/terraform-docs/terraform-docs)
- [tfsec](https://github.com/aquasecurity/tfsec)
- [tflint](https://github.com/terraform-linters/tflint)
- [tfautomv](https://github.com/busser/tfautomv)

It also provides some useful terraform aliases for everyday use.

## Table of content

## ⚙️ Installation

Install from [PowerShell Gallery](https://www.powershellgallery.com/packages)

```powershell
Install-Module terraform-tools -Scope CurrentUser -AllowClobber
```

Or from [Scoop](https://github.com/ScoopInstaller/Extras/blob/master/bucket/git-aliases.json)

```powershell
scoop bucket add extras
scoop install terraform-tools
```

---

⚠️ If you haven't allowed script execution policy, set your script execution policy to `RemoteSigned` or `Unrestricted`.

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 🛂 Usage

You have to import the module to use `terraform-tools`.

Add below command into your PowerShell profile.

```powershell
Import-Module terraform-tools -DisableNameChecking
```

Then restart your PowerShell.  

- First time : will download, install and add all Terraform tools managed by this module to your user `$PATH`
- Then : will only add tools to your `$PATH`

Now you can use wanted tool or uses wanted [aliases](#aliases).

> 🛈 Install terraform command using tfswitch command

```powershell
tfswitch
```


---

⚠️ If you don't have PowerShell profile yet, create it with below command!

```powershell
New-Item -ItemType File $profile
```

### Aliases

Here is the list of availabe aliases provides by this module :

| Alias       | Command              |
| ----------- | -------------------- |
| `tf`        | `terraform`          |
| `tff`       | `tf fmt`             |
| `tfv`       | `tf validate`        |
| `tfi`       | `tf init`            |
| `tfp`       | `tf plan`            |
| `tfa`       | `tf apply`           |
| `tfd`       | `tf destroy`         |
| `tfo`       | `tf output`          |
| `tfr`       | `tf refresh`         |
| `tfs`       | `tf show`            |
| `tfw`       | `tf workspace`       |
| `tffr`      | `tff -recursive`     |
| `tfip`      | `tfi & tfp`          |
| `tfia`      | `tfi & tfa`          |
| `tfid`      | `tfi & tfd`          |
| `tfa!`      | `tfa -auto-approve`  |
| `tfia!`     | `tfi && tfa!`        |
| `tfd!`      | `tfd -auto-approve`  |
| `tfid!`     | `tfi && tfd!`        |
| `tfversion` | `tf version`         |

### Function

`tfws [workspace_name]`

Will execute command :

`tfw select -or-create [workspace_name]`

### Updating Terraform tools

The module comes with a PowerShell function to update all Terraform tools when you want

```powershell
Update-TerraformTools
```

## License

[MIT](./LICENCE)