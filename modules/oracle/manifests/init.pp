class oracle::server {

  $apt_update = "apt-update"
  exec {
    $apt_update:
      command => "/usr/bin/apt-get -y update";
  }

  package {
    ["unzip", "vim"]:
      ensure => installed;
  }

  $install_dirs = [ "/home/vagrant/", "/home/vagrant/oracle/"]
  file {
    "/tmp/copy_all.sh":
      owner  => vagrant,
      source => "puppet:///modules/oracle/copy_all.sh";
    $install_dirs:
      ensure => "directory",
      owner  => vagrant;
  }

  $weblogic_dir = "/home/vagrant/oracle/wlserver_10.3"
  $oracle_obs_dir = "/home/vagrant/oracle/Oracle_OSB_0"
  $local_domain_dir = "/home/vagrant/oracle/user_projects/domains/localDomain"

  $java_home = '/home/vagrant/.sdkman/candidates/java/current'
  file { "/etc/profile.d/java_home.sh":
    content => "export JAVA_HOME=${java_home}",
    mode    => 755
  }

  $men_args = "'-Xms4069m -Xmx4069m -XX:PermSize=1024m -XX:MaxPermSize=2048m'"
  file { "/etc/profile.d/men_args.sh":
    content => "export MEM_ARGS=${men_args}",
    mode    => 755
  }

  $user_men_args =
    "'-Xms4069m -Xmx4069m -XX:NewRatio=2 -XX:PermSize=1024m -XX:MaxPermSize=2048m -XX:+UseParallelGC -XX:MaxGCPauseMillis=200 -XX:GCTimeRatio=19 -XX:+UseParallelOldGC'"
  file { "/etc/profile.d/user_men_args.sh":
    content => "export USER_MEM_ARGS=${user_men_args}",
    mode    => 755
  }

  $copy_installation_files = "Copy Installation Files"
  exec {
    $copy_installation_files:
      command => "/tmp/copy_all.sh",
      timeout => 0,
      user    => root,
      require => [File["/tmp/copy_all.sh"]];
  }

  $create_swap = "Create Swap File"
  exec {
    $create_swap:
      command => "/tmp/create_swapfile.sh",
      timeout => 0,
      user    => root,
      require => [Exec[$copy_installation_files]];
  }

  $install_java = "Install Java"
  exec {
    $install_java:
      command => "/tmp/install_oracle_java.sh",
      timeout => 0,
      user    => vagrant,
      require => [Exec[$create_swap]],
      unless  => "/usr/bin/test -d ${java_home}";
  }

  $install_weblogic = "Install Weblogic"
  exec {
    $install_weblogic:
      environment => ["JAVA_HOME=${java_home}", "MEM_ARGS=${men_args}", "USER_MEM_ARGS=${user_men_args}"],
      command     => "/tmp/install_wls.sh",
      timeout     => 0,
      user        => vagrant,
      require     => [Exec[$install_java]],
      unless      => "/usr/bin/test -d ${weblogic_dir}";
  }

  $unzip_osb = "Unzip OSB"
  exec {
    $unzip_osb:
      command => "/usr/bin/unzip -o ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip",
      timeout => 0,
      cwd     => "/tmp",
      user    => vagrant,
      require => [Package["unzip"], Exec[$install_weblogic]],
      unless  => "/usr/bin/test -d /tmp/ofm_osb_generic_11/Disk1";
  }

  $install_osb = "Install OSB"
  exec {
    $install_osb:
      environment => ["JAVA_HOME=${java_home}", "MEM_ARGS=${men_args}", "USER_MEM_ARGS=${user_men_args}"],
      command     => "/tmp/install_osb.sh  -silent -ResponseFile /tmp/osb_11_inst_silent.rsp",
      timeout     => 0,
      cwd         => "/tmp/ofm_osb_generic_11/Disk1",
      user        => vagrant,
      require     => [Exec[$unzip_osb]],
      unless      => "/usr/bin/test -d ${oracle_obs_dir}";
  }

  $install_domain = "Install Domain"
  exec {
    $install_domain:
      environment => ["JAVA_HOME=${java_home}", "MEM_ARGS=${men_args}", "USER_MEM_ARGS=${user_men_args}"],
      command     => "/tmp/install_domain.sh",
      returns     => 0,
      tries       => 3,
      timeout     => 0,
      user        => vagrant,
      require     => [Exec[$install_osb]],
      unless      => "/usr/bin/test -d ${local_domain_dir}";
  }

  # nohup oracle/user_projects/domains/localDomain/startWebLogic.sh > /dev/null 2>&1 &

  group {
    "puppet":
      ensure => present;
  }

  Exec[$apt_update] -> Package <| |>
}
