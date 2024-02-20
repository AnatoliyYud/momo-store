terraform {
 backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "momo-store-terraform-s3-state"
    region     = "ru-central1"
    key        = "terraform.tfstate"
    access_key = "YCAJEfVXOtEkIVYA3SR2dfVdD"
    secret_key = "YCOMbavNq7Oog401LZQNUX9xf0k8HIZ68LLPRfvK"

    skip_region_validation      = true
    skip_credentials_validation = true
  } 
}
