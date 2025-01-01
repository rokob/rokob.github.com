import React from "react";
import styled from "@emotion/styled";
import { rhythm } from "../utils/typography";
import { niceNum } from "../utils/format";

const Chart = styled.div`
  height: 300px;
  width: 100%;
  position: relative;
  padding-bottom: ${rhythm(1 / 4)};
`;

const ChartWrapper = styled.div`
  position: relative;
  height: 340px;
  width: 100%;
  padding-top: ${rhythm(1 / 4)};
  margin-bottom: ${rhythm(1)};
`;

const HoverData = styled.div`
  width: 100%;
  text-align: center;
`;

export default class BarChart extends React.Component {
  state = { value: null, year: null, month: null };

  enterBar = (bucket) => {
    const parts = bucket[0].split("-");
    const year = parts[0];
    const month = parts[1];
    this.setState({ value: bucket[1], year: year, month: month });
  };

  leaveBar = () => {
    this.setState({ value: null, year: null, month: null });
  };

  render() {
    const { title, dates, data, datum } = this.props;
    let bars = [];
    let max = 0;
    let maxIdx = 0;
    for (let d = 0; d < dates.length; d++) {
      const key = dates[d];
      const value = datum(data[key]) || 0;
      if (value > max) {
        max = value;
        maxIdx = d;
      }
      bars.push([dates[d], value]);
    }
    const bucketCount = max < 10 ? max : 10;
    const bucketSize = Math.ceil(max / bucketCount);
    const buckets = bars.map((bar) => [
      bar[0],
      bar[1],
      Math.round(bar[1] / bucketSize),
    ]);

    let firstDate = dates[0].split("-");
    firstDate = `${niceMonth(firstDate[1])} ${firstDate[0]}`;
    let lastDate = dates[dates.length - 1].split("-");
    lastDate = `${niceMonth(lastDate[1])} ${lastDate[0]}`;
    const barWidthVal = Math.floor((100 / bars.length) * 100) / 100;
    const barWidth = `${barWidthVal}%`;
    const hoverString = this.state.value
      ? `${niceMonth(this.state.month)} ${this.state.year}: ${niceNum(
          this.state.value
        )}`
      : null;
    return (
      <div>
        <h4>{title}</h4>
        <ChartWrapper>
          <div
            css={{
              position: "absolute",
              left: "0",
              bottom: "0",
            }}
          >
            {firstDate}
          </div>
          <div
            css={{
              position: "absolute",
              right: "0",
              bottom: "0",
            }}
          >
            {lastDate}
          </div>
          <div
            css={{
              position: "absolute",
              left: `${barWidthVal * (1.5 + maxIdx)}%`,
              top: "0",
            }}
          >
            {niceNum(max)}
          </div>
          <Chart>
            {buckets.map((bucket, i) => (
              <Bar
                key={i}
                onMouseEnter={() => this.enterBar(bucket)}
                onMouseLeave={() => this.leaveBar()}
                barWidth={barWidth}
                bucket={bucket[2]}
                bucketCount={bucketCount}
              />
            ))}
          </Chart>
          <HoverData>{hoverString}</HoverData>
        </ChartWrapper>
      </div>
    );
  }
}

const Bar = ({ barWidth, bucket, bucketCount, onMouseEnter, onMouseLeave }) => (
  // eslint-disable-next-line jsx-a11y/no-static-element-interactions
  <div
    css={{
      width: barWidth,
      height: `${(bucket / bucketCount) * 100}%`,
      backgroundColor: "#939393",
      display: "inline-block",
      borderRight: "1px solid #000",
      borderLeft: "1px solid #fff",
      borderBottom: "1px solid #939393",
    }}
    onMouseEnter={onMouseEnter}
    onMouseLeave={onMouseLeave}
  >
    <span css={{ display: "none" }}>{bucket}</span>
  </div>
);

const niceMonth = (month) =>
  ({
    "01": "Jan",
    "02": "Feb",
    "03": "Mar",
    "04": "Apr",
    "05": "May",
    "06": "Jun",
    "07": "Jul",
    "08": "Aug",
    "09": "Sep",
    10: "Oct",
    11: "Nov",
    12: "Dec",
  }[month]);
