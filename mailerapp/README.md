# MailerApp

Ambiente contendo:
- Elixir 1.8.1
- Mix 1.8.1
- Phoenix 1.5.13

## Uso

```bash
$ docker-compose run mailerapp bash

$ cd mailerapp

$ mix phx.server
```

## Rotas

- [Enviar Email](#send)
---

<a id="send"></a>

### Enviar Email **[POST /send_email]**

- Request: `POST /send_email`
  - Body:

    ```json
    {
      // Campos obrigatorios
      "from": "from@mail.com",
	    "to": "to@mail.com",
	    "subject": "Email Subject",
	    "text_body": "Report text body",
	    "html_body": "Report html body",

      // Opcional
      "attachment": {
        "content_type": "text/csv", 
        "filename": "sheet.csv",
        // attachment.data precisa estar encodado em Base16
        "data": "656E636F646564"
      }
    }
    ```

- Response (Success)

  - Status Code: 202
  - Message: `The Email is going to be sent`
 
- Response (Error)

  - Status Code: 500
  - Message: `There was an error trying to send the email`