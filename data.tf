data "template_file" "userdata" {
  template = file("${path.module}/templates/userdata.tmpl")
}