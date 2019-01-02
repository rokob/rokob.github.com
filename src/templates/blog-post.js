import React from "react"
import { graphql, Link } from "gatsby"
import Layout from "../components/layout"
import styled from "@emotion/styled"
import { rhythm } from "../utils/typography"
import _ from "lodash"

const Justify = styled.div`
  text-align: justify;
`

const PostTitle = styled.h2`
  margin-bottom: ${rhythm(1 / 2)};
`

const PostDate = styled.h3`
  margin-top: ${rhythm(1 / 2)};
  margin-bottom: ${rhythm(1)};
  color: #bbb;
`

const Metadata = styled.div`
  margin-top: ${rhythm(2)};
  margin-bottom: ${rhythm(1)};
  color: inherit;
`

const MetadataItem = styled.h4`
  margin-top: ${rhythm(1 / 2)};
  margin-bottom: ${rhythm(1 / 4)};
`

export default ({ data }) => {
  const post = data.markdownRemark
  const tags = post.frontmatter.tags

  const tagLinks = tags.map(tag => (
    <Link key={tag} to={`/tags/${tag}/`}>{tag}</Link>
  ))
  const tagLinksJoined = _.flatMap(tagLinks, (a, i) => i ? [', ', a] : [a])

  const sha = post.fields.sha
  const shortSha = sha ? sha.substr(0, 8) : sha;
  const filename = post.parent.relativePath
  const history = `https://github.com/rokob/rokob.github.com/commits/source/content/${filename}`
  const commit = `https://github.com/rokob/rokob.github.com/commit/${sha}`

  return (
    <Layout>
      <PostTitle>{post.frontmatter.title}</PostTitle>
      <PostDate>{post.frontmatter.date}</PostDate>
      <Metadata>
        <MetadataItem>Category: {post.frontmatter.categories}</MetadataItem>
        <MetadataItem><Link to={`/tags`}>Tags:</Link> {tagLinksJoined}</MetadataItem>
      </Metadata>
      <Justify dangerouslySetInnerHTML={{ __html: post.html }} />
      <div>
        <a href={history}>History</a> -- <a href={commit}>{shortSha}</a>
      </div>
    </Layout>
  )
}

export const query = graphql`
  query($slug: String!) {
    markdownRemark(fields: { slug: { eq: $slug } }) {
      html
      frontmatter {
        title
        date(formatString: "DD MMM YYYY")
        categories
        tags
      }
      timeToRead
      wordCount {
        words
      }
      fields {
        sha
      }
      parent {
        ... on File {
          relativePath
        }
      }
    }
  }
`
