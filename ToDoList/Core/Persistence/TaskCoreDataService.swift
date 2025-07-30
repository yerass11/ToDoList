import Foundation
import CoreData

final class TaskCoreDataService {
    private let context = CoreDataStack.shared.context

    func fetchTasks(completion: @escaping ([Task]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            do {
                let result = try self.context.fetch(request).map { $0.toDomainModel() }
                DispatchQueue.main.async {
                    completion(result)
                }
            } catch {
                DispatchQueue.main.async {
                    completion([])
                }
                assertionFailure()
            }
        }
    }

    func saveTasks(_ tasks: [Task], completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            for task in tasks {
                let entity = TaskEntity(context: self.context)
                entity.id = Int64(task.id)
                entity.title = task.title
                entity.descText = task.description
                entity.dateCreated = task.dateCreated
                entity.isCompleted = task.isCompleted
            }

            CoreDataStack.shared.saveContext()
            DispatchQueue.main.async {
                completion?()
            }
        }
    }

    func saveTask(_ task: Task, completion: @escaping () -> Void) {
        let entity = TaskEntity(context: context)
        entity.id = Int64(task.id)
        entity.title = task.title
        entity.descText = task.description
        entity.dateCreated = task.dateCreated
        entity.isCompleted = task.isCompleted

        do {
            try context.save()
            completion()
        } catch {
            assertionFailure()
        }
    }

    func updateTask(_ task: Task, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %lld", task.id)
            do {
                if let entity = try self.context.fetch(request).first {
                    entity.title = task.title
                    entity.descText = task.description
                    entity.dateCreated = task.dateCreated
                    entity.isCompleted = task.isCompleted
                    CoreDataStack.shared.saveContext()
                }
            } catch {
                assertionFailure()
            }

            DispatchQueue.main.async {
                completion?()
            }
        }
    }

    func deleteTask(_ task: Task, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %lld", task.id)
            do {
                if let entity = try self.context.fetch(request).first {
                    self.context.delete(entity)
                    CoreDataStack.shared.saveContext()
                }
            } catch {
                assertionFailure()
            }

            DispatchQueue.main.async {
                completion?()
            }
        }
    }

    func isDataAlreadyLoaded() -> Bool {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.fetchLimit = 1
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }
    
    func toggleTaskCompletion(_ task: Task, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %lld", task.id)
            do {
                if let entity = try self.context.fetch(request).first {
                    entity.isCompleted.toggle()
                    CoreDataStack.shared.saveContext()
                }
            } catch {
                assertionFailure()
            }

            DispatchQueue.main.async {
                completion?()
            }
        }
    }

}
