DevOps Lab Apr2021<br>
EPAM<br>
#DevOps<br>

[![License](https://img.shields.io/badge/license-MIT%20License-brightgreen.svg)](https://opensource.org/licenses/MIT)

<img
src="https://cdn.imgbin.com/11/20/3/imgbin-vagrant-hashicorp-virtual-machine-software-developer-installation-vagrant-ywTTwLKhjrGBxXiPdJNgpkc9D.jpg"
height=48 width=48 alt="Vagrant Logo" /><img
src="https://www.virtualbox.org/graphics/vbox_logo2_gradient.png"
height=48 width=48 alt="VirtualBox Logo" />

Для работы нужны:
1. Установленный Vagrant<br>
2. Установленный VirtualBox + VirtualBox Extension Pack<br>
При утановке VirtualBox Host-Only Ethernet Adapter по-умолчанию добавляется VirtualBox Host-Only Ethernet Adapter. При написании Vagrantfile отталкиваюсь от того что он есть, потому его не учитываю в работе (у меня он переконфигурирован под тестовую сеть 192.168.1.0/24).