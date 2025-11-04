# Backend deployment (free options)

This file contains step-by-step instructions to run and deploy the `backend-citasalud` Spring Boot application using a Docker image and free deploy options (Fly.io is recommended). It also includes important security notes.

---

Quick local build & run (Windows cmd):

```
cd /d "c:\Users\PC6\Desktop\Me+\Universidad\Fábrica Escuela\backend-citasalud"
mvnw.cmd -DskipTests package
java -jar target\CITASaludApplication-0.0.1-SNAPSHOT.jar
```

Run with Docker (build + run locally):

```
cd /d "c:\Users\PC6\Desktop\Me+\Universidad\Fábrica Escuela\backend-citasalud"
docker build -t citasalud-backend:latest .
docker run --rm -p 8080:8080 \
  -e SPRING_DATASOURCE_URL="jdbc:postgresql://host:port/db?sslmode=require" \
  -e SPRING_DATASOURCE_USERNAME="<username>" \
  -e SPRING_DATASOURCE_PASSWORD="<password>" \
  citasalud-backend:latest
```

Important: do NOT keep production credentials in `src/main/resources/application.properties`. Use environment variables in production. Spring Boot will allow environment variables like `SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME`, and `SPRING_DATASOURCE_PASSWORD` to override properties.

Recommended free deployment: Fly.io

1. Install flyctl: https://fly.io/docs/hands-on/install-flyctl/
2. Login: `flyctl auth login`
3. From the backend folder, create and launch an app (the CLI will create `fly.toml`):

```
cd /d "c:\Users\PC6\Desktop\Me+\Universidad\Fábrica Escuela\backend-citasalud"
flyctl launch --name citasalud-backend --builder paketo --port 8080
```

4. Set secrets (use your DB/Credentials or switch to a managed free DB):

```
flyctl secrets set SPRING_DATASOURCE_URL="jdbc:postgresql://<host>:<port>/<db>?sslmode=require"
flyctl secrets set SPRING_DATASOURCE_USERNAME="<username>"
flyctl secrets set SPRING_DATASOURCE_PASSWORD="<password>"
flyctl secrets set APP_JWTSECRET="<your_jwt_secret_base64>"
```

5. Deploy (Fly will detect Dockerfile):

```
flyctl deploy
```

If you want, I can also add a `fly.toml` template and CI workflow to build and deploy on pushes to `main` (GitHub Actions). See `./.github/workflows/deploy-fly.yml` for an example. To use it you must add the following repository secrets in GitHub:

- `FLY_API_TOKEN` (create with `flyctl auth token create` or from Fly dashboard)
- `SPRING_DATASOURCE_URL` (JDBC connection string)
- `SPRING_DATASOURCE_USERNAME`
- `SPRING_DATASOURCE_PASSWORD`
- `APP_JWTSECRET`
- `APP_JWT_EXPIRATION_MS` (optional)

The workflow will set Fly secrets (if present) and run `flyctl deploy --remote-only` on pushes to `main`.
```

Notes on Fly.io:
- Fly provides a free allowance suitable for development/small projects. Check quotas on Fly's site.
- Use Fly secrets to avoid committing credentials.

Alternative free/low-cost options:
- Railway: you can deploy the Dockerfile and set environment variables; free tier availability varies.
- Render: can deploy Docker images; check current free tier status.
- Google Cloud Run: has an always-free tier for very small usage (needs careful config; not strictly unlimited free).

Security recommendations before deploying:
- Move secrets from `application.properties` into environment variables or a secrets store.
- Use an HTTPS-ready host (Fly.io provides automatic TLS for your app domain).
- Rotate JWT secrets and database credentials; use least-privilege DB users.

Troubleshooting:
- If build fails on the remote host due to Java version, ensure the builder or runtime uses Java 21 (Dockerfile uses Eclipse Temurin 21).
- When using an external Postgres server, ensure network access and SSL settings match (see `?sslmode=require`).

If you want, I can also add a `fly.toml` template and CI workflow to build and deploy on pushes to `main`.
