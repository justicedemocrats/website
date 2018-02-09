# Justice Democrats Website

The simplest Elixir app ever! No config required.

Requirements: Elixir 1.4+ (preferably 1.6, as this project uses `mix format`),
and Node 6+.

## Getting Started


```
npm run install
npm run dev
```

You will get errors on your form submissions if you don't have Actionkit secret
keys, but that's ok.

## Commands

Development
```
npm run dev
```

To use with ngrok
```
(In main terminal window)
npm run ngrok

(In another terminal window)
ngrok http 4000 -hostname=[hostname]
```

Production
```
npm run dev
```

## Components

This is a simple website that uses (CosmicJS)[https://cosmicjs.com] for Content
Management, and posts its results to the Actionkit API using our Elixir
Actionkit API wrapper (https://github.com/justicedemocrats/actionkit_ex).

Currently using Webpack + Stylus.
