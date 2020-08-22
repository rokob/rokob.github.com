import React from "react"
import { graphql } from "gatsby"
import styled from "@emotion/styled"
import Layout from "../components/layout"
import _ from "lodash"

import BarChart from "../components/BarChart"

import { niceNum } from "../utils/format"

export default ({ data }) => {
  const books = data.allMarkdownRemark.edges
  let firstYear = null;
  let firstMonth = null;
  let lastMonth = null;
  let lastYear = null;
  let monthly = {}
  let yearly = {}
  let totals = {fiction: 0, nonfiction: 0, bad: 0, okay: 0, good: 0, great: 0, count: 0, pagecount: 0}
  _.each(books, book => {
    const data = book.node.frontmatter
    const date = data.date
    const year = date.split('-')[0]
    const month = date.split('-')[1]
    firstYear = firstYear || year
    firstMonth = firstMonth || month
    lastYear = year
    lastMonth = month
    const tags = data.tags
    const pagecount = data.pagecount || 0
    let monthData = monthly[date] || {fiction: 0, nonfiction: 0, bad: 0, okay: 0, good: 0, great: 0, count: 0, pagecount: 0}
    let yearData = yearly[year] || {fiction: 0, nonfiction: 0, bad: 0, okay: 0, good: 0, great: 0, count: 0, pagecount: 0}
    if (_.includes(tags, 'fiction')) {
      monthData['fiction'] += 1
      yearData['fiction'] += 1
      totals['fiction'] += 1
    }
    if (_.includes(tags, 'nonfiction')) {
      monthData['nonfiction'] += 1
      yearData['nonfiction'] += 1
      totals['nonfiction'] += 1
    }
    if (_.includes(tags, 'bad')) {
      monthData['bad'] += 1
      yearData['bad'] += 1
      totals['bad'] += 1
    }
    if (_.includes(tags, 'okay')) {
      monthData['okay'] += 1
      yearData['okay'] += 1
      totals['okay'] += 1
    }
    if (_.includes(tags, 'good')) {
      monthData['good'] += 1
      yearData['good'] += 1
      totals['good'] += 1
    }
    if (_.includes(tags, 'great')) {
      monthData['great'] += 1
      yearData['great'] += 1
      totals['great'] += 1
    }
    monthData['pagecount'] += pagecount
    yearData['pagecount'] += pagecount
    totals['pagecount'] += pagecount
    monthData['count'] += 1
    yearData['count'] += 1
    totals['count'] += 1

    monthly[date] = monthData
    yearly[year] = yearData
  })
  const months = ["01", "02", "03", "04", "05", "06",
    "07", "08", "09", "10", "11", "12"];
  firstYear = parseInt(firstYear)
  lastYear = parseInt(lastYear)
  let years = []
  for (let y = firstYear; y <= lastYear; y++) {
    years.push(String(y))
  }
  let dates = []
  for (let m = months.indexOf(firstMonth); m < months.length; m++) {
    dates.push(`${String(firstYear)}-${months[m]}`);
  }
  for (let y = 1; y < years.length - 1; y++) {
    for (let m = 0; m < months.length; m++) {
      dates.push(`${years[y]}-${months[m]}`);
    }
  }
  for (let m = 0; m <= months.indexOf(lastMonth); m++) {
    dates.push(`${String(lastYear)}-${months[m]}`);
  }
  return (
  <Layout>
    <p>My New Year's Resolution in 2015 was to read a book a week. I thought it was attainable based on my reading habits prior to that point. However without any real data, I was not sure how difficult it would be. I have used this blog to keep track of what I was reading, adding a little bit of metadata to the posts to keep track of things like genre and how good or bad I thought the book was.</p>

<p>The reading a book a week project was a success, but without that specific goal my reading habits have fallen off a little bit. How do I know this? I continued to keep track of the data by posting here every time I read a book. Recently I added the page counts for all of the books that I read to the metadata that I collect. This allowed me to create some graphs that I found pretty interesting. As part of the build process for this site, I will now be autogenerating these graphs so that this page stays up to date with the details of my reading habits.</p>

<p>Each graph has an equal width bar for each month starting with January 2015 and ending at the month in which I last posted about a book (usually the current month). The maximum value should be labeled near the month in which that value was attained. The height of the bars is scaled linearly between zero and the max.</p>
      <BarChart
        title="Books read per month"
        dates={dates}
        data={monthly}
        datum={(val) => val && val['count']} />
      <BarChart
        title="Pages read per month"
        dates={dates}
        data={monthly}
        datum={(val) => val && val['pagecount']} />
      <BarChart
        title="Ratio of pages read to number of books"
        dates={dates}
        data={monthly}
        datum={(val) => val && val['count'] > 0 && Math.round(val['pagecount'] / val['count'])} />
      {years.map(year => (
        <Yearly key={year} year={year} data={yearly[year]} />
      ))}
      <Yearly key={'total'} year={'Total'} data={totals} />
  </Layout>
  )
}

const RightCell = styled.td`
  text-align: right;
`

const Yearly = ({ year, data }) => (
  data ? (
  <table>
    <caption><h4>{year}</h4></caption>
    <tbody>
    <tr>
      <td>Books Read</td>
      <RightCell>{niceNum(data.count)}</RightCell>
    </tr>
    <tr>
      <td>Pages Read</td>
      <RightCell>{niceNum(data.pagecount)}</RightCell>
    </tr>
    <tr>
      <td>Bad</td>
      <RightCell>{data.bad}</RightCell>
    </tr>
    <tr>
      <td>Okay</td>
      <RightCell>{data.okay}</RightCell>
    </tr>
    <tr>
      <td>Good</td>
      <RightCell>{data.good}</RightCell>
    </tr>
    <tr>
      <td>Great</td>
      <RightCell>{data.great}</RightCell>
    </tr>
    <tr>
      <td>Fiction</td>
      <RightCell>{data.fiction}</RightCell>
    </tr>
    <tr>
      <td>Nonfiction</td>
      <RightCell>{data.nonfiction}</RightCell>
    </tr>
    </tbody>
  </table>
  ) : null
)

export const query = graphql`
  query {
    allMarkdownRemark(
      filter: { frontmatter: { categories: { eq: "book" } } }
      sort: { fields: [frontmatter___date], order: ASC }
    ) {
      edges {
        node {
          frontmatter {
            date(formatString: "YYYY-MM")
            tags
            pagecount
          }
        }
      }
    }
  }
`
