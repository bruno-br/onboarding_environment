# Phoenix

Ambiente contendo:
- Elixir 1.8.1
- Mix 1.8.1
- Phoenix 1.5.13

## Uso

```bash
$ docker-compose run phoenix bash

$ cd myapp

$ mix phx.server
```


---

## Rotas


- [Listar Produtos  (index)](#index)

- [Criar produto (create)](#create)

- [Detalhes de um produto (show)](#show)

- [Atualizar Produto (update)](#update)
  
- [Apagar Produto (destroy)](#destroy)


---

<a id="index"></a>

### Listar Produtos (index) **[GET /products]**

Quando não é passado nenhum filtro, todos os produtos são listados:

- Request: `GET /products`

- Response (OK)

  - Status Code: 200
  
  - Body:

    ```json
    {
      "products": [
        {
          "id": "61a918f018a4c200a09a9f9e",
          "sku": "CC-LED-32-V302-P",
          "name": "Monitor V302 Preto",
          "description": "Monitor LED Preto",
          "amount": 10,
          "price": 1200.0
        },
        {
          "id": "61a9180318a4c200a09a9f98",
          "sku": "CC-LED-32-V302-C",
          "name": "Monitor V302 Cinza",
          "description": "Monitor LED Cinza",
          "amount": 12,
          "price": 1200.0
        }
      ]
    }
    ```

É possível filtrar os produtos a serem listados:

- Request: `GET /products?amount=10&price=1200`

- Response (OK)

  - Status Code: 200
  
  - Body:

    ```json
    {
      "products": [
        {
          "id": "61a918f018a4c200a09a9f9e",
          "sku": "CC-LED-32-V302-P",
          "name": "Monitor V302 Preto",
          "description": "Monitor LED Preto",
          "amount": 10,
          "price": 1200.0
        }
      ]
    }
    ```

<a id="create"></a>

### Criar produto (create) **[POST /products]**


- Request 
  
  - Body:
  
    ```json
    {
      "product": {
        "sku": "CC-LED-32-V302-P",
        "name": "Monitor V302",
        "description": "Monitor LED Preto",
        "amount": 10,
        "price": 1200.0
      }
    }
    ```
- Response (Created)

  - Status Code: 201
  
  - Body:
  
    ```json
    {
      "product": {
        "id": "61a918f018a4c200a09a9f9e",
        "sku": "CC-LED-32-V302-P",
        "name": "Monitor V302",
        "description": "Monitor LED Preto",
        "amount": 10,
        "price": 1200.0
      }
    }
    ```

- Response (Unprocessable Entity)
  
  - Status Code: 422
  
  - Body: 
  
    ```json
    {
      "errors": {
        "price": [
          "can't be blank"
        ]
      }
    }
      ```

- Response (Bad Request)
  
  - Status Code: 400

<a id="show"></a>

### Detalhes de um produto (show) **[GET /products/:id]**

- Request
  
  - Parameters:
  
    **id** - ID do produto

- Response (OK)

  - Status Code: 200

  - Body:

    ```json
    {
      "product": {
        "id": "61a918f018a4c200a09a9f9e",
        "sku": "CC-LED-32-V302-P",
        "name": "Monitor V302",
        "description": "Monitor LED Preto",
        "amount": 10,
        "price": 1200.0
      }
    }
    ```

- Response (Not Found)
 
  - Status Code: 404

<a id="update"></a>

### Atualizar Produto (update) **[PATCH /products/:id]**


- Request
  
  - Parameters:
  
    **id** - ID do produto

  - Body:
  
    Informar no Body as propriedades que serao alteradas
    
    ```json
    {
      "product":{
        "amount": 1
      }
    }
    ```

- Response (OK)

  - Status Code: 200
  
   - Body:
    
      ```json
      {
        "product": {
          "id": "61a918f018a4c200a09a9f9e",
          "sku": "CC-LED-32-V302-P",
          "name": "Monitor V302",
          "description": "Monitor LED Preto",
          "amount": 1,
          "price": 1200.0
        }
      }
      ```
  

- Response (Unprocessable Entity)
  
  - Status Code: 422
  
  - Body: 
  
    ```json
      {
        "errors": {
          "amount": [
            "is invalid"
          ]
        }
      }
      ```


- Response (Not Found)
 
  - Status Code: 404


<a id="destroy"></a>

### Apagar Produto (destroy) **[DELETE /products/:id]**

- Request
  
  - Parameters:
  
    **id** - ID do produto

- Response (OK)

  - Status Code: 200

  - Body:

    ```json
    {
      "product": {
        "id": "61a918f018a4c200a09a9f9e",
        "sku": "CC-LED-32-V302-P",
        "name": "Monitor V302",
        "description": "Monitor LED Preto",
        "amount": 10,
        "price": 1200.0
      }
    }
    ```

- Response (Not Found)
 
  - Status Code: 404

