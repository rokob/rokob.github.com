import React from "react";
import Layout from "../components/layout";
import { StaticImage } from "gatsby-plugin-image";

const About = () => (
  <Layout>
    <p>
      The venerable personal website about page. Maybe one day I will put
      content back here, but for now this is it.
    </p>
    <p>
      If you are interested you can find the{" "}
      <a
        href="https://github.com/rokob/rokob.github.com/tree/source"
        rel="noopener noreferrer"
        target="_blank"
      >
        source that generates this site here
      </a>
      .
    </p>
    <StaticImage src="../../content/images/dogmap.jpg" alt="Doggos" />
  </Layout>
);

export default About;
