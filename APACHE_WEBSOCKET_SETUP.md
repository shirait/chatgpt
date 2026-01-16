# Apache + Passenger での WebSocket 設定手順

## 問題
ActionCable（WebSocket）接続が失敗する場合、Apacheの設定でWebSocketのアップグレードを許可する必要があります。

## 手順

### 1. 必要なApacheモジュールを有効化

```bash
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_wstunnel
sudo a2enmod rewrite
sudo a2enmod headers
```

### 2. Apacheの設定ファイルを編集

通常、設定ファイルは以下のいずれかにあります：
- `/etc/apache2/sites-available/chatgpt.conf`
- `/etc/apache2/sites-available/000-default.conf`
- `/etc/apache2/apache2.conf`

### 3. WebSocket設定を追加

`apache_websocket_config.conf.example` の内容を参考に、以下の設定を追加してください：

```apache
<VirtualHost *:80>
    ServerName 192.168.10.105

    # 既存のPassenger設定...
    PassengerAppRoot /home/chatgpt/websocket_test/chatgpt
    PassengerBaseURI /web_socket
    PassengerAppEnv production

    # WebSocket接続のプロキシ設定
    RewriteEngine On

    # WebSocket接続の判定とプロキシ
    RewriteCond %{HTTP:Upgrade} =websocket [NC]
    RewriteCond %{HTTP:Connection} upgrade [NC]
    RewriteRule ^/web_socket/cable$ ws://127.0.0.1:$(PassengerPort)/cable [P,L]

    # または、Locationディレクティブを使用する場合
    <Location /web_socket/cable>
        ProxyPass ws://127.0.0.1:$(PassengerPort)/cable
        ProxyPassReverse ws://127.0.0.1:$(PassengerPort)/cable

        RewriteEngine on
        RewriteCond %{HTTP:Upgrade} websocket [NC]
        RewriteCond %{HTTP:Connection} upgrade [NC]
        RewriteRule .* ws://127.0.0.1:$(PassengerPort)%{REQUEST_URI} [P,L]
    </Location>
</VirtualHost>
```

### 4. Passengerのポートを確認

Passengerが使用しているポートを確認：

```bash
sudo passenger-status
```

または、Passengerの設定ファイルで確認：
```bash
cat /etc/apache2/mods-available/passenger.conf
```

固定ポートを使う場合は、`$(PassengerPort)` を実際のポート番号に置き換えてください。

### 5. Apache設定の構文チェック

```bash
sudo apache2ctl configtest
```

### 6. Apacheを再起動

```bash
sudo systemctl restart apache2
# または
sudo service apache2 restart
```

## トラブルシューティング

### WebSocket接続がまだ失敗する場合

1. **Passengerのポートを確認**
   ```bash
   sudo passenger-status
   ```

2. **Apacheのエラーログを確認**
   ```bash
   sudo tail -f /var/log/apache2/error.log
   ```

3. **ファイアウォールの確認**
   WebSocket接続に必要なポートが開いているか確認：
   ```bash
   sudo ufw status
   ```

4. **Passengerのログを確認**
   ```bash
   tail -f /home/chatgpt/websocket_test/chatgpt/log/production.log
   ```

### 代替案: 固定ポートを使用

`$(PassengerPort)` が動作しない場合、固定ポートを使用：

```apache
# Passengerの設定で固定ポートを指定
PassengerPort 3000

# WebSocket設定で固定ポートを使用
RewriteRule ^/web_socket/cable$ ws://127.0.0.1:3000/cable [P,L]
```

## 参考資料

- [Passenger + ActionCable の設定](https://www.phusionpassenger.com/docs/advanced_guides/action_cable/)
- [Apache mod_proxy_wstunnel](https://httpd.apache.org/docs/2.4/mod/mod_proxy_wstunnel.html)

