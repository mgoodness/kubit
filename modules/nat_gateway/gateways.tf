/*
Copyright 2017 Michael Goodness

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

resource "aws_eip" "nat" {
   count = "${length(var.subnets["availability_zones"])}"
   vpc = true
}

resource "aws_nat_gateway" "nat" {
  count = "${length(var.subnets["availability_zones"])}"
  depends_on = [
    "aws_eip.nat",
  ]
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id = "${element(var.public_subnet_ids, count.index)}"
}
