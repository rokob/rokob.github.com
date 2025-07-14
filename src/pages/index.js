import React from "react";
import { Link, graphql } from "gatsby";
import styled from "@emotion/styled";
import { rhythm } from "../utils/typography";
import Layout from "../components/layout";
import Seo from "../components/seo";

const PostLink = styled(Link)`
  text-decoration: none;
  color: inherit;
`;

const PostTitle = styled.h3`
  margin-bottom: ${rhythm(1 / 4)};
`;

const PostDate = styled.span`
  color: #bbb;
`;

const Index = ({ data }) => (
  <Layout>
    <p>
      I am currently working at{" "}
      <a
        href="https://www.reddit.com"
        rel="noopener noreferrer"
        target="_blank"
      >
        Reddit
      </a>
      . Over the past twelve or so years I have worked at{" "}
      <a
        href="https://www.opensea.io"
        rel="noopener noreferrer"
        target="_blank"
      >
        OpenSea
      </a>
      ,{" "}
      <a
        href="https://www.google.com"
        rel="noopener noreferrer"
        target="_blank"
      >
        Google
      </a>
      ,{" "}
      <a
        href="https://www.rollbar.com"
        rel="noopener noreferrer"
        target="_blank"
      >
        Rollbar
      </a>
      ,{" "}
      <a href="https://alan.eu" rel="noopener noreferrer" target="_blank">
        Alan
      </a>
      ,{" "}
      <a
        href="https://www.flexport.com"
        rel="noopener noreferrer"
        target="_blank"
      >
        Flexport
      </a>
      , and{" "}
      <a
        href="https://www.facebook.com/"
        rel="noopener noreferrer"
        target="_blank"
      >
        Facebook
      </a>{" "}
      primarily as a Staff+ level software engineer.
    </p>

    <p>
      Before going to Facebook, I was a Postdoctoral Scholar in Mathematical
      Finance at the{" "}
      <a
        href="http://www.caltech.edu/"
        rel="noopener noreferrer"
        target="_blank"
      >
        California Institute of Technology
      </a>
      ; and before that I did my PhD at{" "}
      <a
        href="http://www.princeton.edu/"
        rel="noopener noreferrer"
        target="_blank"
      >
        Princeton University
      </a>{" "}
      focusing on applied probability and game theory.
    </p>

    <div>
      <h1>Recent Posts</h1>
      {data.allMarkdownRemark.edges.map(({ node }) => (
        <div key={node.id}>
          <PostLink to={node.fields.slug}>
            <PostTitle>
              {node.frontmatter.title}{" "}
              <PostDate>— {node.frontmatter.date}</PostDate>
            </PostTitle>
            <p>{node.frontmatter.excerpt || node.excerpt}</p>
          </PostLink>
        </div>
      ))}
      <Link to={`/blog/2`}>See more</Link>
    </div>
  </Layout>
);

export default Index;

export const Head = () => <Seo />;

// limit: 5
// this needs to match constants.PostsOnIndex, but we can't interpolate
export const query = graphql`
  query {
    allMarkdownRemark(
      filter: { frontmatter: { published: { ne: false } } }
      sort: { frontmatter: { date: DESC } }
      limit: 5
    ) {
      edges {
        node {
          id
          frontmatter {
            title
            date(formatString: "DD MMMM, YYYY")
            excerpt
          }
          fields {
            slug
          }
          excerpt
        }
      }
    }
  }
`;
