import random

import dagger
from dagger import dag, function, object_type


@object_type
class InfrastructureDocumentation:
    @function
    async def publish(self, source: dagger.Directory) -> str:
        """Publish the application container after building and testing it on-the-fly"""
        await self.test(source)
        return await self.build(source).publish(
            f"ttl.sh/infrastructure-documentation-{random.randrange(10**8)}"
        )

    @function
    def build(self, source: dagger.Directory) -> dagger.Container:
        """Build the application container"""
        build = (
            self.build_env(source)
            .with_exec(["mkdocs", "build", "--site-dir", "./output"])
            .directory("./output")
        )
        return (
            dag.container()
            .from_("nginx:1.25-alpine")
            .with_directory("/usr/share/nginx/html", build)
            .with_exposed_port(80)
        )
    
    @function
    async def test(self, source: dagger.Directory) -> str:
        """Return the result of running unit tests"""
        return await (
            self.build_env(source)
            .with_exec(["mkdocs", "get-deps"])
            .stdout()
        )

    @function
    def build_env(self, source: dagger.Directory) -> dagger.Container:
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