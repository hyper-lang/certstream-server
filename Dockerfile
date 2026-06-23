FROM elixir:1.14.5-otp-25

# System deps (NO alpine — avoids SSL issues)
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    inotify-tools \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Hex/Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy dependency files first (cache-friendly)
COPY mix.exs mix.lock ./

# Install deps (includes your vendor override if declared in mix.exs)
RUN mix deps.get

# Now copy everything INCLUDING your patch
COPY . .

# Compile everything (including vendor/easy_ssl)
RUN mix compile

CMD ["mix", "run", "--no-halt"]
