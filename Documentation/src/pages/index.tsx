import React from 'react';
import clsx from 'clsx';
import Layout from '@theme/Layout';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import { LazyIframe } from 'react-lazy-media';
import styles from './index.module.css';
// import HomepageFeatures from '@site/src/components/HomepageFeatures';
import DownloadOnTheAppStore from '@site/static/img/appstore.svg';
import DownloadOnTheMacAppStore from '@site/static/img/macappstore.svg';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className="container">
        <h1 className={clsx('hero__title', styles.heroTitle)}>{siteConfig.title}</h1>
        <p className={clsx('hero__subtitle', styles.heroSubtitle)}>{siteConfig.tagline}</p>
        <div className={styles.buttons}>
          <div className={styles.appstoreButtons}>
            <Link to="about:blank">
              <DownloadOnTheAppStore />
            </Link>
            <Link to="about:blank">
              <DownloadOnTheMacAppStore />
            </Link>
          </div>
          <Link
            className="button button--secondary button--lg"
            to="/docs/intro">
            Get Started
          </Link>
        </div>
      </div>
    </header>
  );
}

export default function Home(): JSX.Element {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title="Home"
      description={siteConfig.tagline}>
      <HomepageHeader />
      <main className={styles.video}>
        {/* <HomepageFeatures /> */}
        <LazyIframe
          width="560"
          height="315"
          src="https://www.youtube.com/embed/9-wj8eMUEn0"
          title="YouTube video player"
          frameBorder="0"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowFullScreen
        />
      </main>
    </Layout>
  );
}
