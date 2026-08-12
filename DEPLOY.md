# Execução local em Docker

Este marco usa `CONTENT_STORE=file`, sem Supabase, IA, domínio, proxy ou HTTPS.
O conteúdo fica no volume nomeado `businessos_content`, montado em `/app/content`.

## Configuração

Opcionalmente, crie um arquivo `.env` local (ignorado pelo Git):

```dotenv
FOUNDER_EMAIL=founder@example.com
BUSINESSOS_PORT=3000
BUSINESSOS_IMAGE_TAG=file-local
```

`FOUNDER_EMAIL` deve ser substituído pelo e-mail da instância antes de qualquer
uso compartilhado. Não coloque chaves de Supabase ou IA neste marco.

## Build, seed e início

```bash
docker compose build app
docker compose up content-init
docker compose --profile seed run --rm --no-deps seed
docker compose up -d app
docker compose ps
curl -I http://127.0.0.1:3000/founder
```

O seed é idempotente: pode ser executado novamente e preserva entidades já
existentes. A aplicação e o seed usam UID/GID `1001`; somente `content-init`
executa brevemente como root para ajustar a permissão de um volume novo.

## Atualização e rollback

Para preservar uma imagem identificável, defina `BUSINESSOS_IMAGE_TAG` antes de
construir, por exemplo com o SHA curto do commit:

```bash
BUSINESSOS_IMAGE_TAG=file-<commit> docker compose build app
BUSINESSOS_IMAGE_TAG=file-<commit> docker compose up -d app
```

Para voltar a uma imagem já construída, use a tag anterior sem `--build`:

```bash
BUSINESSOS_IMAGE_TAG=file-<commit-anterior> docker compose up -d --no-build app
```

Não use `docker compose down -v` se quiser preservar o conteúdo. `docker compose
down` e a recriação do container mantêm o volume nomeado.
