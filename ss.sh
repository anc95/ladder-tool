#!/bin/sh
source './log.sh'

# {
#     "server":"my_server_ip",
#     "server_port":8388,
#     "local_address": "127.0.0.1",
#     "local_port":1080,
#     "password":"mypassword",
#     "timeout":300,
#     "method":"aes-256-cfb",
#     "fast_open": false
# }

sever=""
server_port="2333"
local_address="127.0.0.1"
local_port="1080"
timeout=300
method="aes-256-cfb"
fast_open=false
password="password"

shadowsocks_config_file=/etc/shadowsocks.json
shadowcocks_service_file=/etc/systemd/system/shadowsocks.service


install_shadowsocks() {
  if command -v pip &>/dev/null; then
    info "开始下载shadowsocks"
    ldnf install ibsodium python34-pip
    pip3 install  git+https://github.com/shadowsocks/shadowsocks.git@master
  fi
}

edit_config() {
  case $1 in
    server)
      info "请输入服务器地址(格式如144.123.12.34):/c"
      read input

      if [ -z $input ]; then
        error "请重新输入"
        edit_config $1
      else
        server=$input
      fi
    ;;
    server_port)
      info "请输入端口号(默认:2333)"
      read input
      echo $server_port
      if [ ! -z $input ]; then
        echo true
        server_port=$input
      fi
      echo $server_port
    ;;
    local_address)
      info "请输入本地监听地址(默认:127.0.0.1):/c"
      read input

      if [ ! -z $input ]; then
        local_address=$input
      fi
    ;;
    local_port)
      info "请输入本地监听端口号(默认:1080):/c"
      read input

      if [ ! -z $input ]; then
        local_port=$input
      fi
    ;;
    timeout)
      info "请输入超时时间(默认:300):/c"
      read input

      if [ ! -z $input ]; then
        timeout=$input
      fi
    ;;
    password)
      info "请输入密码(默认:password):/c"
      success "1)"
      read input

      if [ ! -z $input ]; then
        password=$input
      fi
    ;;
    method)
      info "请选择加密方式(默认:aes-256-cfb):/c"
      success "1)"
      read input

      if [ ! -z $input ]; then
        method=$input
      fi
    ;;
  esac
}

config_shadowsocks() {
  sudo touch $shadowsocks_config_file
  edit_config "server"
  edit_config "server_port"
  edit_config "local_address"
  edit_config "local_port"
  edit_config "timeout"
  edit_config "method"
  edit_config "password"
  write_config
}

write_config() {
  keys=("server" "server_port" "local_address" "local_port" "timeout" "method", "password")
  values=(${server} ${server_port} ${local_address} ${local_port} ${timeout} ${method}, ${password})

  echo "{" | sudo tee $shadowsocks_config_file

  len=${#keys[@]}
  suffix=","
  for ((i=0;i<$len;i++));do
    if [ `expr $len - 1` -eq $i ]; then
      suffix=""
    fi
    echo "\"${keys[$i]}\": \"${values[$i]}\"$suffix" | sudo tee -a $shadowsocks_config_file
  done

  echo "}" | sudo tee -a $shadowsocks_config_file
}

init_service() {
  cp ./ss.service $shadowcocks_service_file
  systemctl enable shadowsocks.service
  systemctl start shadowsocks.service
}

install_shadowsocks
config_shadowsocks
init_service
