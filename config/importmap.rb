# Pin npm packages by running ./bin/importmap

pin "application"
pin "delete_links"
pin "navbar_burger", to: "navbar_burger.js"
pin "@rails/actioncable", to: "actioncable.esm.js"
pin_all_from "app/javascript/channels", under: "channels"
