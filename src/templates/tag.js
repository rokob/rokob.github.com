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
  color: #555;
`;

const Tag = ({ pageContext, data }) => {
  const { tag } = pageContext;
  const { edges, totalCount } = data.allMarkdownRemark;
  const tagHeader = `${totalCount} post${
    totalCount === 1 ? "" : "s"
  } tagged with "${tag}"`;

  return (
    <Layout>
      <h1>{tagHeader}</h1>
      {edges.map(({ node }) => {
        const { date, title } = node.frontmatter;
        const path = node.fields.slug;
        return (
          <div key={node.id}>
            <PostLink to={path}>
              <PostTitle>
                {title} <PostDate>— {date}</PostDate>
              </PostTitle>
              <p>{node.excerpt}</p>
            </PostLink>
          </div>
        );
      })}
      <Link to="/tags">All tags</Link>
    </Layout>
  );
};

export default Tag;

export const Head = ({ location, pageContext }) => {
  const { tag } = pageContext;
  return <Seo pathname={location.pathname} title={`Tag ${tag}`} />;
};

export const query = graphql`
  query markdownContentForTagPage($tag: String) {
    allMarkdownRemark(
      limit: 2000
      sort: { frontmatter: { date: DESC } }
      filter: { frontmatter: { tags: { in: [$tag] } } }
    ) {
      totalCount
      edges {
        node {
          frontmatter {
            title
            date(formatString: "DD MMMM, YYYY")
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
