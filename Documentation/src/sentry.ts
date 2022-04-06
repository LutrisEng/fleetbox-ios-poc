import * as Sentry from "@sentry/react";
import { BrowserTracing } from "@sentry/tracing";
import ExecutionEnvironment from "@docusaurus/ExecutionEnvironment";

if (ExecutionEnvironment.canUseDOM) {
  Sentry.init({
    dsn: "https://a089c1dced604148b6b1f631f8323bc5@o1155807.ingest.sentry.io/6312132",
    integrations: [new BrowserTracing()],
    tracesSampleRate: 1.0,
  });
}
