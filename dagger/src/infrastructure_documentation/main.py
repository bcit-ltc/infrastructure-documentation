import random

from typing import Annotated

import dagger
from dagger import Doc, DefaultPath, dag, function, object_type


@object_type
class InfrastructureDocumentation:
    @function
    async def publish(self, source: dagger.Directory) -> str:
        """Publish the application container after building and testing it on-the-fly"""
        
        image = await self.dockerbuild(source)
        ete_result = await self.ete_testing(image)
        
        return await image.publish(
            f"infrastructure-documentation-{random.randrange(10**8)}"
        )

    @function
    def build(self, source: dagger.Directory) -> dagger.Container:
        """Build the application container"""
        build = (
            self.install_dep(source)
            .with_exec(["mkdocs", "build", "--site-dir", "./public"])
            .directory("./public")
        )
        return (
            dag.container()
            .from_("nginx:1.25-alpine")
            .with_directory("/usr/share/nginx/html", build)
            .with_exposed_port(80)
        )
    
    @function
    def dev(self, source: Annotated[dagger.Directory, DefaultPath("./")]) -> dagger.Container:
        """Return the result of running unit tests"""
        # directory = dagger.Directory("./")
        return (
            # self.install_dep(source)
            dag.container()
            .from_("squidfunk/mkdocs-material")
            .with_mounted_directory("/docs", source)
            # .with_mounted_cache("/root/.npm", node_cache)
            .with_workdir("/docs")
            .with_exec(["pip", "install", "Pygments", "pymdown-extensions", "mkdocs-git-revision-date-localized-plugin"])
            # .with_exec(["mkdocs", "serve", "-a", "0.0.0.0:8000"])
            .with_exposed_port(8000)
            .as_service(args=["mkdocs", "serve", "-a", "0.0.0.0:8000"])
            # .stdout()
        )
    
    @function
    def devdev(self, source: dagger.Directory) -> dagger.Container:
        """Return the result of running unit tests"""
        return (
             dag.container()
            .from_("node:alpine3.21")
            .with_exec(["npm", "init", "-y"])
            .with_exec(["npx", "create-react-app@latest", "myapp"])
            .with_workdir("/myapp")
            .with_exec(["npm", "start"])
            .with_exposed_port(8000)
            .stdout()
        )

    # 
    @function
    async def ete_testing(self, src: dagger.Container) -> None:
        """Return the result of running end-to-end tests"""
        
        return await (
            self.dockerbuild(src)
            .with_exec(["cypress", "some ete testing command"])
            .stdout()
        )

    # using a Dockerfile to build and return a container
    @function
    async def dockerbuild(
        self,
        src: Annotated[
            dagger.Directory,
            DefaultPath("./")
        ],
    ) -> dagger.Container:
        """Build and image from existing Dockerfile"""
        ref = await src.docker_build()
        return await (
            ref.with_exposed_port(8080)
        )
    
    @function
    def somenginx(self, source: dagger.Directory) -> dagger.Container:
        """Return the result of running unit tests"""
        return (
            dag.container()
            .from_("nginx:1.25-alpine")
            # .with_directory("/usr/share/nginx/html", build)
            .with_exposed_port(80)
        )
    
    @function
    async def unit_testing(self, source: dagger.Directory) -> str:
        """Return the result of running unit tests"""
        return await (
            self.install_dep(source)
            .with_exec(["mkdocs", "get-deps"])
            .stdout()
        )

    @function
    async def runsemver(
        self,
        src: Annotated[
            dagger.Directory,
            DefaultPath("./")
        ],
    ) -> dagger.Container:
        """Run Semver """

        build = (
            self.buildsemver(src)
            .directory(src)
            .with_file("/app/.releaserc", dag.file().with_content("""
            {
                "branches": [
                    "main"
                ],
                "tagFormat": "${version}",
                "plugins": [
                    "@semantic-release/commit-analyzer",
                    "@semantic-release/release-notes-generator",
                    [
                        "@semantic-release/exec",
                        {
                            "verifyReleaseCmd": "echo ${nextRelease.version} > NEXT_VERSION"
                        }
                    ],
                    "@semantic-release/github"
                ]
            }
            """))
            .with_exec(["npx", "semantic-release"])
        )
        return await build

    @function
    async def buildsemver(
        self,
        src: Annotated[
            dagger.Directory,
            DefaultPath("./")
        ],
    ) -> dagger.Container:
        """Build a semver container"""
        node_cache = dag.cache_volume("node")
        return (
            dag.container()
            .from_("node:alpine3.21")
            .with_directory("/app", src)
            .with_workdir("/app")
            .with_exec(["npm", "init", "-y"])
            .with_exec(["npm", "install", "semantic-release", "@semantic-release/exec"])
            .with_exec(["npm", "audit", "signatures"])
            )
    
    @function
    def installdependencies(self, source: dagger.Directory) -> dagger.Container:
        """Build a ready-to-use development environment"""
        node_cache = dag.cache_volume("node")
        return (
            dag.container()
            .from_("squidfunk/mkdocs-material")
            .with_directory("/docs", source)
            # .with_mounted_cache("/root/.npm", node_cache)
            .with_workdir("/docs")
            .with_exec(["pip", "install", "Pygments", "pymdown-extensions", "mkdocs-git-revision-date-localized-plugin"])
        )