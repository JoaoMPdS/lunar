package = "lunar"
version = "release-1"
source = {
   url = "*** please add URL for source tarball, zip or repository here ***"
}
description = {
   homepage = "*** please enter a project homepage ***",
   license = "*** please specify a license ***"
}
build = {
   type = "builtin",
   modules = {}
}
dependencies = {
   "lua >= 5.1, < 5.4",
   "lunajson",
   "luafilesystem"
}