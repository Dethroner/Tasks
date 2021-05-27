# DevOps Lab Apr2021<br>
EPAM<br>
#DevOps<br>

[![License](https://img.shields.io/badge/license-MIT%20License-brightgreen.svg)](https://opensource.org/licenses/MIT)

<img
src="../main/02Git/images/git.png"
height=48 width=48 alt="Git Logo" /><img
src="../main/02Git/images/vagrant.jpg"
height=48 width=48 alt="Vagrant Logo" /><img
src="../main/02Git/images/VB.png"
height=48 width=48 alt="VirtualBox Logo" /><img
src="../main/02Git/images/CentOS.png"
height=48 width=48 alt="CentOS Logo" /><img
src="../main/02Git/images/apache.png"
height=48 width=48 alt="Apache Logo" /><img
src="../main/02Git/images/tomcat.png"
height=48 width=48 alt="Tomcat Logo" /><img
src="../main/02Git/images/nginx.png"
height=48 width=48 alt="Nginx Logo" />

Для работы нужны:
1. Установленный Git.<br>
2. Установленный Vagrant<br>
3. Установленный VirtualBox + VirtualBox Extension Pack<br>
При утановке VirtualBox Host-Only Ethernet Adapter по-умолчанию добавляется VirtualBox Host-Only Ethernet Adapter. При написании Vagrantfile отталкиваюсь от того что он есть, потому его не учитываю в работе.

<details><summary>01. Centos 7.</summary>
<p>

## CentOS 7:

<li>Для выполнения задания 5 использовал [VM's](https://github.com/Dethroner/Tasks/tree/main/01CentOS/1).</li>

<li>Для простых задач использую [VM](https://github.com/Dethroner/Tasks/tree/main/01CentOS/2) подключаюсь, так:</li>

```
ssh appuser@192.168.1.5 -i ~/.ssh/appuser
```

<b>!!!</b> Пользователям надо заменить [appuser.pub](../main/01CentOS/2/files/.sshkey/appuser.pub) на собственный.
</p>
</details>

<details><summary>02. Git.</summary>
<p>

## Git:

Результат выполнения задания опубликован в [Report'e](../main/02Git/Report.md)

</p>
</details>

