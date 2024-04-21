// ET-5895 To obtain Docker credentials one must have a pair of AK/SK of the dedicated user. There are two options:
// 1. Manually in the OTC Console, see https://docs.otc.t-systems.com/software-repository-container/umn/image_management/obtaining_a_long-term_valid_login_command.html
// 2. Uncomment the underlying output and copy-paste values from it

# output "ci_cd_docker_credentials" {
#   value = {
#     login    = format("%s@%s", "${var.name}-ci-cd", opentelekomcloud_identity_credential_v3.ci_cd.access)
#     login_key_command = <<SHELL
# printf "${opentelekomcloud_identity_credential_v3.ci_cd.access}" | openssl dgst -binary -sha256 -hmac "${opentelekomcloud_identity_credential_v3.ci_cd.secret}" | od -An -vtx1 | sed 's/[ \n]//g' | sed 'N;s/\n//'
# SHELL
#   }
# }
