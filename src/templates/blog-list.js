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

const BlogList = ({ pageContext, data }) => {
  const { numPages, pageNumber, prev, next } = pageContext;

  return (
    <Layout>
      <h1>
        Page {pageNumber} of {numPages}
      </h1>
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
      <Pagination
        numPages={numPages}
        pageNumber={pageNumber}
        prev={prev}
        next={next}
      />
    </Layout>
  );
};

const PaginationLink = styled(Link)`
  padding-right: ${rhythm(1 / 4)};
`;
const PaginationFirstLink = styled(Link)`
  padding-left: ${rhythm(1 / 4)};
  padding-right: ${rhythm(1 / 4)};
`;
const PaginationLastLink = styled(Link)`
  padding-right: ${rhythm(1 / 4)};
`;
const PaginationPlain = styled.span`
  padding-right: ${rhythm(1 / 4)};
`;
const PaginationFirstPlain = styled.span`
  padding-left: ${rhythm(1 / 4)};
  padding-right: ${rhythm(1 / 4)};
`;
const PaginationLastPlain = styled.span`
  padding-right: ${rhythm(1 / 4)};
`;

const Pagination = ({ numPages, pageNumber, prev, next }) => {
  const context = 2;
  const showAllLimit = 15;
  let pages = [];
  if (numPages <= showAllLimit) {
    pages = Array.from({ length: numPages }).map((_, i) => {
      return {
        key: i,
        to: i + 1 === pageNumber ? null : i > 0 ? `/blog/${i + 1}` : `/`,
        name: `${i + 1}`,
        first: i === 0,
        last: i === numPages - 1,
      };
    });
  } else {
    let key = 0;
    if (pageNumber - context > 1) {
      pages.push({ key: key++, to: `/`, name: "1", first: true, last: false });
    }
    if (pageNumber - context > 2) {
      pages.push({ key: key++, to: null, name: "..." });
    }
    const leftContext = Math.min(
      Math.max(pageNumber - context + 1, 1),
      context
    );
    Array.from({ length: leftContext }).forEach((_, i) => {
      const to = pageNumber - (context - i);
      const first = pageNumber - context <= 1 && to < 2;
      pages.push({
        key: key++,
        to: to < 2 ? `/` : `/blog/${to}`,
        name: `${to < 2 ? 1 : to}`,
        first: first,
      });
    });
    pages.push({ key: key++, to: null, name: `${pageNumber}` });
    const rightContext = Math.min(Math.max(0, numPages - pageNumber), context);
    Array.from({ length: rightContext }).forEach((_, i) => {
      const to = pageNumber + i + 1;
      const last = pageNumber + context >= numPages && to >= numPages;
      pages.push({ key: key++, to: `/blog/${to}`, name: `${to}`, last: last });
    });
    if (pageNumber + context < numPages) {
      if (pageNumber + context < numPages - 1) {
        pages.push({ key: key++, to: null, name: "..." });
      }
      pages.push({
        key: key,
        to: `/blog/${numPages}`,
        name: `${numPages}`,
        first: false,
        last: true,
      });
    }
  }
  return (
    <div>
      <Link to={prev}>Prev</Link>
      {" -"}
      {pages.map(({ key, to, name, first, last }) => {
        if (to && first) {
          return (
            <PaginationFirstLink key={key} to={to}>
              {name}
            </PaginationFirstLink>
          );
        } else if (to && last) {
          return (
            <PaginationLastLink key={key} to={to}>
              {name}
            </PaginationLastLink>
          );
        } else if (to) {
          return (
            <PaginationLink key={key} to={to}>
              {name}
            </PaginationLink>
          );
        } else if (first) {
          return <PaginationFirstPlain key={key}>{name}</PaginationFirstPlain>;
        } else if (last) {
          return <PaginationLastPlain key={key}>{name}</PaginationLastPlain>;
        } else {
          return <PaginationPlain key={key}>{name}</PaginationPlain>;
        }
      })}
      {next && "- "}
      {next && <Link to={next}>Next</Link>}
    </div>
  );
};

export default BlogList;

export const Head = ({ location, pageContext }) => {
  const { numPages, pageNumber } = pageContext;
  return (
    <Seo
      pathname={location.pathname}
      title={`Blog list page ${pageNumber} of ${numPages}`}
    />
  );
};

export const query = graphql`
  query blogListQuery($skip: Int!, $limit: Int!) {
    allMarkdownRemark(
      filter: { frontmatter: { published: { ne: false } } }
      sort: { frontmatter: { date: DESC } }
      limit: $limit
      skip: $skip
    ) {
      totalCount
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
