---
title: Introduction
---

The LTC's infrastructure has been serving blogs, multimedia assets, simple websites, and full database-driven applications since 2010. As the demands for our services grow, our infrastructure requires renewal and operational maintenance.

In 2021 the Course Production team underook a large project to re-design and renew the LTC's aging infrastructure. The project had the following goals:

* To replace aging, single machine test and production deployment endpoints
* To create more *industry-standard* environments with development, staging, and production deployment endpoints
* To ensure infrastructure maintenance is straightforward and relatively easy
* To ensure growth potential
* To avoid vendor lock-in
* To facilitate the establishment of a contemporary development workflow that uses containers/images
* To minimize costs

The LTC now has a modern, highly-available collection of systems that provide the department with the capability to deliver contemporary educational resources to the institute.

![ltc-infrastructure](assets/ltc-infrastructure-simple.png#only-light)
![ltc-infrastructure](assets/ltc-infrastructure-simple-dark.png#only-dark)

!!! tip ""

    The LTC infrastructure operators:

    * practice infrastructure as code (IaC) and use CI/CD pipelines to limit manual deployment and configuration
    * configure the infrastructure through the files outlined in the "LTC Infrastructure" group of projects

    By using configuration files and recording their changes in a version control system, we are able to better know what has been installed, where, and when something was last updated (operational awareness).
