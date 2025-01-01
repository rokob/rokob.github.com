import React from "react";
import styled from "@emotion/styled";
import { StaticQuery, Link, graphql } from "gatsby";

import { rhythm } from "../utils/typography";

const Container = styled.div`
  margin: 0 auto;
  max-width: 800px;
  padding-bottom: ${rhythm(2)};
  padding-top: ${rhythm(1.5)};

  @media only screen and (max-width: 801px) {
    width: 93%;
  }
`;

const ChildWrapper = styled.div`
  margin-top: ${rhythm(2)};
`;

const Title = styled.h3`
  margin-top: 0;
  margin-bottom: ${rhythm(1)};
  display: inline-block;
  font-style: normal;
`;

const RightLinks = styled.div`
  float: right;
`;

const RightLink = styled(Link)`
  padding-left: ${rhythm(1 / 2)};
`;

const TheComponent = ({ children }) => (
  <StaticQuery
    query={graphql`
      query {
        site {
          siteMetadata {
            title
          }
        }
      }
    `}
    render={(data) => (
      <Container>
        <Link to={`/`}>
          <Title>{data.site.siteMetadata.title}</Title>
        </Link>
        <RightLinks>
          <RightLink to={`/reading`}>Reading</RightLink>
          <RightLink to={`/about`}>About</RightLink>
        </RightLinks>
        <ChildWrapper>{children}</ChildWrapper>
      </Container>
    )}
  />
);

export default TheComponent;
