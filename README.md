# FinNest — Online Banking (Full Stack)

FinNest is a full-stack online banking application: a **Spring Boot** REST API
backend (`finnest-api`) and a **React + Redux** single-page frontend
(`finnest-web`). Users can register, log in, open accounts, transfer funds,
deposit/withdraw, make payments, and view a live-updating account chart.



## Tech Stack

**Backend (`finnest-api`):** Java 8, Spring Boot 2.7, Spring Data JPA,
Spring Web, JWT (jjwt), MySQL
**Frontend (`finnest-web`):** React, Redux, Redux Thunk, React Router, Material UI

## Project Structure

```
.
├── finnest-api/    # Spring Boot REST API (Maven project)
└── finnest-web/    # React + Redux single-page app
```

## Prerequisites

- **JDK 8+** and **Maven**
- **MySQL** running locally
- **Node.js** and **npm**

## Backend setup (`finnest-api`)

1. Create a MySQL database:
   ```sql
   CREATE DATABASE finnest;
   ```
2. Update `finnest-api/src/main/resources/application.properties` with your
   MySQL username/password if they differ from the defaults.
3. (Recommended) Override the JWT secret via an environment-specific value
   instead of the default in `application.properties`:
   ```
   finnest.app.secret=<your-long-random-secret>
   ```
4. Build and run:
   ```bash
   cd finnest-api
   mvn spring-boot:run
   ```
   The API starts on `http://127.0.0.1:8070`.

## Frontend setup (`finnest-web`)

```bash
cd finnest-web
npm install
npm start
```

The app runs on `http://localhost:3000` and talks to the API at port `8070`.

## Features

- User registration with email account verification
- JWT-based login / logout
- Open and manage multiple bank accounts
- Transfers between accounts, deposits, withdrawals, and payments
- Account and transaction history
- Live-updating account-balance chart
- Redux-connected components for real-time UI updates

## License

Released under the [MIT License](./LICENSE) for the modifications, with
attribution to the original author [@Berko01](https://github.com/Berko01).
