# Onboarding
## Instruções
- Faça um fork desse repositório.
- Crie um branch a partir do master para cada desafio.
- Crie um PR do branch do desafio para o master quando finalizar.
## Instalação
```bash
docker-compose build
```

## Ambientes

- [Rails](rails)
- [MyApp](myapp)
- [MailerApp](mailerapp)

## Serviços

### Mongo

Iniciar o mongo
```bash
docker-compose up -d mongo
```
### Redis

Iniciar o redis
```bash
docker-compose up -d redis
```
### ElasticSearch, Logstash e Kibana

Iniciar o ELK
```bash
docker-compose up -d elk
```
### RabbitMQ

Iniciar o RabbitMQ
```bash
docker-compose up -d rabbitmq
```
### Sentry
https://develop.sentry.dev/self-hosted/
