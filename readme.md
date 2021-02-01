# Linux install automatisation

## vps install

---

php / apache / mariadb / phpmyadmin / rkhunter / fail2ban

- mariadb client install
  - Enter current password for root (enter for none): **<< No Password - Press Enter**
  - Switch to unix_socket authentication [Y/n] **N << Disabling Unix Socket login and enabling password Login**
  - Remove anonymous users? [Y/n] **Y << Remove Anonymous users**
  - Disallow root login remotely? [Y/n] **Y << Disallow root login remotely**
  - Remove test database and access to it? [Y/n] **Y << Remove test database**
  - Reload privilege tables now? [Y/n] **Y << Reload privilege**

## wordpress install

---

Install last wordpress version in current path and defaults plugins list. You can configure the list of plugins by alter the script
