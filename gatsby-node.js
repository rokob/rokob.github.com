const { createFilePath } = require(`gatsby-source-filesystem`);
const path = require(`path`);
const { execSync } = require(`child_process`);
const _ = require(`lodash`);
const { PostsOnIndex } = require(`./src/constants`);

exports.onCreateNode = ({ node, getNode, actions }) => {
  const { createNodeField } = actions;
  if (node.internal.type === `MarkdownRemark`) {
    var sha = "unknown";
    try {
      sha = execSync(
        `git log -n 1 --pretty=format:%H -- ${node.fileAbsolutePath}`,
        { stdio: ["ignore", "pipe", "ignore"] }
      );
      sha = sha.toString();
    } catch (e) {}
    const slug = createFilePath({ node, getNode, basePath: `content` });
    const sourceName = getNode(node.parent).sourceInstanceName;
    createNodeField({
      node,
      name: `slug`,
      value: `/blog${slug}`,
    });
    createNodeField({
      node,
      name: `sourceName`,
      value: sourceName,
    });
    createNodeField({
      node,
      name: `sha`,
      value: sha,
    });
  }
};

exports.createPages = ({ graphql, actions }) => {
  const { createPage } = actions;
  const postListTemplate = path.resolve(`./src/templates/blog-list.js`);
  const postTemplate = path.resolve(`./src/templates/blog-post.js`);
  const tagTemplate = path.resolve(`./src/templates/tag.js`);

  return new Promise((resolve, reject) => {
    graphql(`
      {
        allMarkdownRemark(
          filter: { frontmatter: { published: { ne: false } } }
          sort: { frontmatter: { date: DESC } }
          limit: 1000
        ) {
          edges {
            node {
              frontmatter {
                tags
                categories
              }
              fields {
                slug
              }
            }
          }
        }
      }
    `)
      .then((result) => {
        const posts = result.data.allMarkdownRemark.edges;
        const postsPerPage = 15;
        const numPages = Math.ceil(
          (posts.length - PostsOnIndex) / postsPerPage
        );
        Array.from({ length: numPages }).forEach((_, i) => {
          createPage({
            path: `/blog/${i + 2}`,
            component: postListTemplate,
            context: {
              limit: postsPerPage,
              skip: PostsOnIndex + i * postsPerPage,
              prev: i > 0 ? `/blog/${i + 1}` : `/`,
              next: i < numPages - 1 ? `/blog/${i + 3}` : null,
              numPages: numPages + 1,
              pageNumber: i + 2,
            },
          });
        });

        posts.forEach(({ node }) => {
          createPage({
            path: node.fields.slug,
            component: postTemplate,
            context: {
              slug: node.fields.slug,
            },
          });
        });

        let tags = [];
        _.each(posts, (edge) => {
          if (_.get(edge, "node.frontmatter.tags")) {
            tags = tags.concat(edge.node.frontmatter.tags);
          }
        });
        tags = _.uniq(tags);
        tags.forEach((tag) => {
          createPage({
            path: `/tags/${_.kebabCase(tag)}/`,
            component: tagTemplate,
            context: {
              tag,
            },
          });
        });

        resolve();
      })
      .catch(reject);
  });
};
