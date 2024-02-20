variable "cloud_id" {
  type    = string
  default = "b1gtfmkiigqftefctpga"
}

variable "folder_id" {
  type    = string
  default = "b1go28aedu7n5u38e0rf"
}

variable "token" {
  type    = string
  default = "t1.9euelZqMi8yYyZ2KlIzPx5OSjZCYi-3rnpWakMyaz5jOkZ6bmZ6QyMvNlJfl8_dmR0FS-e8sIDcU_d3z9yZ2PlL57ywgNxT9zef1656VmsmSxpvJjseLncyWkomRkpyb7_zN5_XrnpWals6PmpOJjZaekI2Mi5CYm5nv_cXrnpWayZLGm8mOx4udzJaSiZGSnJs.ULZ0Qt6WBnPgS6mGXMSzd3vaBX5siz2DYZnxnvJ_2EkTGr9OC6fUKEI_BARiSnd8ZT0NoY0v4PMRXMSU2FwVAQ"
}
variable "zone" {
  type    = string
  default = "ru-central1-a"
}
variable "domain" {
  type    = string
  default = "aymomo.ru"
  description = "DNS domain"
  sensitive = true
}

