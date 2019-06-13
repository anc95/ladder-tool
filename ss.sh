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
      info "请输入服务器地址(格式如144.123.12.34)"
      read input

      if [-z input]; then
        error "请重新输入"
        edit_config $1
      fi
    ;;
    server_port)
      info "请输入端口号(默认:2333)"
      read input

      if [-n $input]; then
        server_port=$input
      fi
    ;;
    local_address)
      info "请输入本地监听地址(默认:127.0.0.1)"
      read input

      if [-n $input]; then
        local_address=$input
      fi
    ;;
    local_port)
      info "请输入本地监听端口号(默认:1080)"
      read input

      if [-n $input]; then
        local_port=$input
      fi
    ;;
    timeout)
      info "请输入超时时间(默认:300)"
      read input

      if [-n $input]; then
        timeout=$input
      fi
    ;;
    method)
      info "请选择加密方式(默认:aes-256-cfb)"
      success "1)"
      read input

      if [-n $input]; then
        method=$input
      fi
}

config_shadowsocks() {
  touch "/etc/shadowsocks.json"
  edit_config "server"
  edit_config "server_port"
  edit_config "local_address"
  edit_config "local_port"
  edit_config "timeout"
  edit_config "method"
}

install_pip
config_shadowsocks