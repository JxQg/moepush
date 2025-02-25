# 构建阶段
FROM node:20-alpine AS builder

# 安装 pnpm
RUN npm install -g pnpm@10.4.1

# 设置工作目录
WORKDIR /build

# 复制依赖文件
COPY package.json pnpm-lock.yaml ./

# 安装依赖
RUN pnpm install --frozen-lockfile

# 复制源代码
COPY . .

# 运行阶段
FROM node:20-alpine AS runner
WORKDIR /app

# 安装必要的运行时依赖
RUN apk add --no-cache sqlite

# 安装 pnpm
RUN npm install -g pnpm@10.4.1

# 从构建阶段复制必要文件
COPY --from=builder /build/node_modules ./node_modules
COPY --from=builder /build/package.json ./
COPY --from=builder /build/next.config.js ./
COPY --from=builder /build/public ./public
COPY --from=builder /build/app ./app
COPY --from=builder /build/lib ./lib
COPY --from=builder /build/wrangler.example.json ./
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN mkdir -p /app/.wrangler/state/v3/d1

EXPOSE 3000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["pnpm", "run", "dev"]