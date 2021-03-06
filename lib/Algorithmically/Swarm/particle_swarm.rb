# frozen_string_literal: true

module Algorithmically
  module Swarm
    class ParticleSwarm
      def initialize(problem_size, max_gens, search_space, vel_space, pop_size, max_vel, c1, c2)
        @search_space = search_space
        @vel_space = vel_space
        @search_space = Array.new(problem_size) { |_i| [-5, 5] }
        @vel_space = Array.new(problem_size) { |_i| [-1, 1] }
        best = search(max_gens, @search_space, @vel_space, pop_size, max_vel, c1, c2)
        puts "done! Solution: f=#{best[:cost]}, s=#{best[:position].inspect}"
      end

      def objective_function(vector)
        vector.inject(0.0) { |sum, x| sum + (x**2.0) }
      end

      def random_vector(minmax)
        Array.new(minmax.size) do |i|
          minmax[i][0] + ((minmax[i][1] - minmax[i][0]) * rand)
        end
      end

      def create_particle(search_space, vel_space)
        particle = {}
        particle[:position] = random_vector(search_space)
        particle[:cost] = objective_function(particle[:position])
        particle[:b_position] = Array.new(particle[:position])
        particle[:b_cost] = particle[:cost]
        particle[:velocity] = random_vector(vel_space)
        particle
      end

      def get_global_best(population, current_best = nil)
        population.sort! { |x, y| x[:cost] <=> y[:cost] }
        best = population.first
        if current_best.nil? || (best[:cost] <= current_best[:cost])
          current_best = {}
          current_best[:position] = Array.new(best[:position])
          current_best[:cost] = best[:cost]
        end
        current_best
      end

      def update_velocity(particle, gbest, max_v, c1, c2)
        particle[:velocity].each_with_index do |v, i|
          v1 = c1 * rand * (particle[:b_position][i] - particle[:position][i])
          v2 = c2 * rand * (gbest[:position][i] - particle[:position][i])
          particle[:velocity][i] = v + v1 + v2
          particle[:velocity][i] = max_v if particle[:velocity][i] > max_v
          particle[:velocity][i] = -max_v if particle[:velocity][i] < -max_v
        end
      end

      def update_position(part, bounds)
        part[:position].each_with_index do |v, i|
          part[:position][i] = v + part[:velocity][i]
          if part[:position][i] > bounds[i][1]
            part[:position][i] = bounds[i][1] - (part[:position][i] - bounds[i][1]).abs
            part[:velocity][i] *= -1.0
          elsif part[:position][i] < bounds[i][0]
            part[:position][i] = bounds[i][0] + (part[:position][i] - bounds[i][0]).abs
            part[:velocity][i] *= -1.0
          end
        end
      end

      def update_best_position(particle)
        return if particle[:cost] > particle[:b_cost]

        particle[:b_cost] = particle[:cost]
        particle[:b_position] = Array.new(particle[:position])
      end

      def search(max_gens, search_space, vel_space, pop_size, max_vel, c1, c2)
        pop = Array.new(pop_size) { create_particle(search_space, vel_space) }
        gbest = get_global_best(pop)
        max_gens.times do |gen|
          pop.each do |particle|
            update_velocity(particle, gbest, max_vel, c1, c2)
            update_position(particle, search_space)
            particle[:cost] = objective_function(particle[:position])
            update_best_position(particle)
          end
          gbest = get_global_best(pop, gbest)
          puts " > gen #{gen + 1}, fitness=#{gbest[:cost]}"
        end
        gbest
      end
    end
  end
end
