#!/usr/bin/env bash


#
#  If need to add extra packages repo:
# >  yum-config-manager --add-repo http://dl.fedoraproject.org/pub/epel/6/x86_64/
# > rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6


#
# Create jenkins user
#
useradd -d /var/lib/jenkins -s /bin/bash jenkins

#
# Install JDK 7
# 
yum -y install java-1.7.0-openjdk-devel

#
# Install wget
#
yum -y install wget

echo "Installing Maven 3.0.5..."
if [ ! -d "/opt/apache-maven-3.0.5" ]; then
    # TODO: we need a consistent URL for Maven! 
    wget http://www.bizdirusa.com/mirrors/apache/maven/maven-3/3.0.5/binaries/apache-maven-3.0.5-bin.tar.gz 
    tar -x -C /opt -f apache-maven-3.0.5-bin.tar.gz
    ln -s /opt/apache-maven-3.0.5/bin/mvn /usr/local/bin/mvn
fi

yum -y install git

#
# Need postgres package for rails pg gem
#
yum install -y postgresql-devel

#
# Install rvm as jenkins user
#

# rvm requirements
yum install -y libyaml-devel libffi-devel readline-devel zlib-devel openssl-devel
su -c 'curl -L https://get.rvm.io | bash' jenkins
su -c 'rvm install 1.9.3' jenkins
su -c 'rvm --default use 1.9.3' jenkins
su -c 'gem install rake'

#
# Install Jenkins
#
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
yum install -y jenkins

/etc/init.d/jenkins restart

su -c 'git config --global user.name "Jenkins-ci-local"' jenkins
su -c 'git config --global user.email "jenkins@localhost"' jenkins

#
# Generate ssh key and upload to jenkins
#

#
# Install JRuby
#
if [ ! -d "/opt/jruby" ]; then
  wget http://jruby.org.s3.amazonaws.com/downloads/1.7.10/jruby-bin-1.7.10.tar.gz
  tar -x -C /opt -f jruby-bin-1.7.10.tar.gz
  ln -s /opt/jruby-1.7.10 /opt/jruby
  echo 'export JRUBY_HOME=/opt/jruby' >> ~jenkins/.bash_profile
  echo 'export PATH=$JRUBY_HOME/bin:$PATH' >> ~jenkins/.bash_profile
fi

#
# Install Node.js we need a javascript runtime
#
yum install -y nodejs

#
# Was seeing an error with JRuby:
# load error: fast_xs -- java.lang.RuntimeException: callback-style handles are no longer supported in JRuby
#     problem in hpricot so removed
#

#
# Neet to install and configure Postgres 9.1
#
#  Had to create brainspace user with CREATEDB perms
#    - run rake db:create
#    - run rake db:migrate

#
# Need to figure out a way to get database.yml in config dir for tests
#


#
# Install Jenkins plugins - git, github, rake, ruby, rvm, cucumber, build pipeline
#
