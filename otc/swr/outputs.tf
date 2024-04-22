output "ci_cd_docker_credentials" {
  sensitive = true
  value = {
    login             = format("%s@%s", "${var.name}-ci-cd", opentelekomcloud_identity_credential_v3.ci_cd.access)
    login_key_command = <<SHELL
printf "${opentelekomcloud_identity_credential_v3.ci_cd.access}" | openssl dgst -binary -sha256 -hmac "${opentelekomcloud_identity_credential_v3.ci_cd.secret}" | od -An -vtx1 | sed 's/[ \n]//g' | sed 'N;s/\n//'
SHELL
  }
}
