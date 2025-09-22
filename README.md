## <a name="table">Table of Contents</a>

1. [Introduction](#introduction)
2. [Tech Stack](#tech-stack)
3. [Quick Start](#quick-start)

## <a name="introduction">Introduction</a>

This is the backend service for the SwapnPlay project, built with Phoenix (Elixir).
It provides API endpoints for managing game trading, user interactions, and integrations with Supabase for persistence.

## <a name="tech-stack">Tech Stack</a>

- Elixir
- Phoenix Framework
- PostgreSQL

## <a name="quick-start">Quick Start</a>

Follow these steps to set up the project locally on your machine.

**--> Prerequisites**

Make sure you have the following installed on your machine:

- [Elixir](https://elixir-lang.org/)
- [Phoenix Framework](https://www.phoenixframework.org/)
- [PostgreSQL](https://www.postgresql.org/)

**--> Cloning the Repository**

```bash
git clone git@github.com:mbanixox/swapnplay_backend.git
cd swapnplay_backend
```

**--> Installation**

Install the project dependencies using mix:

```bash
mix deps.get
```

**--> Set Up Environment Variables**

Create a new file named `.env` in the root of your project and add the following content:

```env
DATABASE_URL=
SECRET_KEY_BASE=
```

You can use the provided `.env.example` in the root folder as a template. Make sure to replace the placeholders with your actual values.

**--> Run database setup**

```bash
mix ecto.setup
```

This will create the database, run migrations, and seed initial data.

**--> Running the Project**

```bash
mix phx.server
```

Open [http://localhost:4000](http://localhost:4000) in your browser to view the project.