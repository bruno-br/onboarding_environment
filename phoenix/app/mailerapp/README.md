# MailerApp

## Rotas

- [Enviar Email](#send)
---

<a id="send"></a>

### Enviar Email **[POST /send_email]**

- Request: `POST /send_email`
  - Body:

    ```json
    {
      "from": "from@mail.com",
	    "to": "to@mail.com",
	    "subject": "Email Subject",
	    "text_body": "Report text body",
	    "html_body": "Report html body"
    }
    ```

- Response (Success)

  - Status Code: 202
  - Message: `The Email is going to be sent`
 
- Response (Error)

  - Status Code: 500
  - Message: `There was an error trying to send the email`