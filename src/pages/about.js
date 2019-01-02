import React from "react"
import Layout from "../components/layout"
import doggo from "../../content/images/dogmap.jpg"

export default () => (
  <Layout>
    <p>The venerable personal website about page. Maybe one day I will put content back here, but for now this is it.</p>
    <img src={doggo} alt="Doggos" />
  </Layout>
)
