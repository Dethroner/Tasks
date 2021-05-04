DevOps Lab Apr2021<br>
EPAM<br>
#DevOps<br>

[![License](https://img.shields.io/badge/license-MIT%20License-brightgreen.svg)](https://opensource.org/licenses/MIT)

<img
src="https://cdn.imgbin.com/11/20/3/imgbin-vagrant-hashicorp-virtual-machine-software-developer-installation-vagrant-ywTTwLKhjrGBxXiPdJNgpkc9D.jpg"
height=48 width=48 alt="Vagrant Logo" /><img
src="https://www.virtualbox.org/graphics/vbox_logo2_gradient.png"
height=48 width=48 alt="VirtualBox Logo" /><img
src="https://4.bp.blogspot.com/-pzbhEk68WJA/V_foOw_QWzI/AAAAAAAAlgg/9_xcZCTxhWo_S2ftXEyFdCw5Wk-CunNzwCLcB/s1600/centos-logo.png"
height=48 width=48 alt="CentOS Logo" />

Для работы нужны:
1. Установленный Vagrant<br>
2. Установленный VirtualBox + VirtualBox Extension Pack<br>
При утановке VirtualBox Host-Only Ethernet Adapter по-умолчанию добавляется VirtualBox Host-Only Ethernet Adapter. При написании Vagrantfile отталкиваюсь от того что он есть, потому его не учитываю в работе (у меня он переконфигурирован под тестовую сеть 192.168.1.0/24).

<details><summary>01. Centos 7.</summary>
<p>

## CentOS 7:

<li>Для выполнения задания 5 использовал [VM's](Tasks/01CentOS/1/).</li>

<li>Для простых задач использую [VM](Tasks/01CentOS/2/) подключаюсь, так:</li><br>
```
ssh appuser@192.168.1.5 -i ~/.ssh/appuser
```
<br><b>!!!</b> Пользователям надо заменить [appuser.pub](Tasks\01CentOS\2\files\.sshkey\) на собственный.
</p>
</details>
