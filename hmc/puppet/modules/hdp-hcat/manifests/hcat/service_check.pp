#
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
#
class hdp-hcat::hcat::service_check() 
{
  $unique = hdp_unique_id_and_date()
  $smoke_test_user = $hdp::params::smokeuser
  $output_file = "/apps/hive/warehouse/hcatsmoke${unique}"

  $test_cmd = "fs -test -e ${output_file}" 
  
  anchor { 'hdp-hcat::hcat::service_check::begin':}

  file { '/tmp/hcatSmoke.sh':
    ensure => present,
    source => "puppet:///modules/hdp-hcat/hcatSmoke.sh",
    mode => '0755',
  }

  exec { '/tmp/hcatSmoke.sh':
    command   => "su - ${smoke_test_user} -c 'sh /tmp/hcatSmoke.sh hcatsmoke${unique}'",
    tries     => 3,
    try_sleep => 5,
    require   => File['/tmp/hcatSmoke.sh'],
    path      => '/usr/sbin:/sbin:/usr/local/bin:/bin:/usr/bin',
    notify    => Hdp-hadoop::Exec-hadoop['hcat::service_check::test'],
    logoutput => "true"
  }

  hdp-hadoop::exec-hadoop { 'hcat::service_check::test':
    command     => $test_cmd,
    refreshonly => true,
    require     => Exec['/tmp/hcatSmoke.sh'],
    before      => Anchor['hdp-hcat::hcat::service_check::end'] 
  }
  
  anchor{ 'hdp-hcat::hcat::service_check::end':}
}
