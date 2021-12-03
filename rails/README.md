# Rails

Ambiente contendo:
- Ruby 2.2.7
- Rails 4

## Uso

```bash
$ docker-compose run rails bash

$ cd myapp

$ bundle install

$ rails s
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

### Listar Produtos  (index) **[GET /products]**

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

<a id="create"></a>

### Criar produto (create) **[POST /products]**


- Request 
  
  - Body:
  
    ```json
    {
      "sku": "CC-LED-32-V302-P",
      "name": "Monitor V302",
      "description": "Monitor LED Preto",
      "amount": 10,
      "price": 1200.0
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

- Response (Bad Request)
  
  - Status Code: 400

  - Body:

    ```json
    {}
    ```

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

  - Body:

    ```json
    {}
    ```

<a id="update"></a>

### Atualizar Produto (update) **[PATCH /products/{:id}]**


- Request
  
  - Parameters:
  
    **id** - ID do produto

  - Body:
  
    Informar no Body as propriedades que serao alteradas
    
    ```json
    {
      "amount": "1"
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

- Response (Not Found)
 
  - Status Code: 404

  - Body:

    ```json
    {}
    ```

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

  - Body:

    ```json
    {}
    ```
