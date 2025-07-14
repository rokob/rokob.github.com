import React from "react";
import Layout from "../components/layout";
import Seo from "../components/seo";
import kebabCase from "lodash/kebabCase";
import { Link, graphql } from "gatsby";

const TagsPage = ({
  data: {
    allMarkdownRemark: { group },
  },
}) => (
  <Layout>
    <h1>Tags</h1>
    <ul>
      {group.map((tag) => (
        <li key={tag.fieldValue}>
          <Link to={`/tags/${kebabCase(tag.fieldValue)}/`}>
            {tag.fieldValue} ({tag.totalCount})
          </Link>
        </li>
      ))}
    </ul>
  </Layout>
);

export default TagsPage;

export const Head = () => <Seo pathname="/tags" />;

export const query = graphql`
  query {
    allMarkdownRemark(
      limit: 2000
      filter: { frontmatter: { published: { ne: false } } }
    ) {
      group(field: { frontmatter: { tags: SELECT } }) {
        fieldValue
        totalCount
      }
    }
  }
`;
