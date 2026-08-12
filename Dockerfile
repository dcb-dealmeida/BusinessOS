FROM node:24-bookworm-slim AS base

WORKDIR /app

ENV NEXT_TELEMETRY_DISABLED=1

RUN groupadd --gid 1001 businessos \
  && useradd --uid 1001 --gid businessos --create-home --shell /usr/sbin/nologin businessos

FROM base AS build

ARG PNPM_VERSION=10.34.0

RUN npm install --global "pnpm@${PNPM_VERSION}"

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .
RUN pnpm build

FROM base AS runtime

ARG PNPM_VERSION=10.34.0

RUN npm install --global "pnpm@${PNPM_VERSION}"

COPY --from=build --chown=businessos:businessos /app ./
RUN mkdir -p /app/content && chown businessos:businessos /app/content

ENV NODE_ENV=production \
    CONTENT_STORE=file \
    CONTENT_ROOT=/app/content \
    PORT=3000 \
    HOSTNAME=0.0.0.0

USER businessos

EXPOSE 3000

CMD ["pnpm", "start"]
